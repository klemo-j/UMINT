# ============================================================
# UMINT Zadanie 8 - Kompletný script (Extrémna GPU Optimalizácia)
# UPRAVENÉ: VGG16 nahradené za oveľa rýchlejší AlexNet
# ============================================================

# ── 1. Importy ───────────────────────────────────────────────
import os, copy, random
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader
from torchvision import datasets, transforms, models as tv_models
import numpy as np
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
from tqdm import tqdm

# ── 2. Základné nastavenia ───────────────────────────────────
DEVICE = torch.device("cuda" if torch.cuda.is_available() else "cpu")
print(f"Zariadenie: {DEVICE}")

# 🔥 OPTIMALIZÁCIA 1: Zrýchlenie konvolúcií na NVIDIA kartách
if torch.cuda.is_available():
    torch.backends.cudnn.benchmark = True

DATA_ROOT = "./data"

SELECTED_CLASSES = [
    "apple_pie", "caesar_salad", "clam_chowder", "edamame", "french_fries",
    "hamburger", "hot_dog", "ice_cream", "sushi", "waffles"
]
NUM_CLASSES = len(SELECTED_CLASSES)

EPOCHS = 40
LR = 1e-4
BATCH_SIZE = 64
NUM_RUNS = 3
VAL_SPLIT = 0.1

MEAN = [0.485, 0.456, 0.406]
STD = [0.229, 0.224, 0.225]


# ── 3. Reprodukovateľnosť ────────────────────────────────────
def set_seed(seed=42):
    torch.manual_seed(seed)
    np.random.seed(seed)
    random.seed(seed)
    if torch.cuda.is_available():
        torch.cuda.manual_seed_all(seed)


# ── 4. Transformácie ─────────────────────────────────────────
transform_base = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    transforms.Normalize(MEAN, STD),
])

transform_aug = transforms.Compose([
    transforms.Resize((256, 256)),
    transforms.RandomCrop(224),
    transforms.RandomHorizontalFlip(),
    transforms.RandomRotation(15),
    transforms.ColorJitter(brightness=0.2, contrast=0.2, saturation=0.2),
    transforms.ToTensor(),
    transforms.Normalize(MEAN, STD),
])


# ── 5. Globálna trieda Datasetu ──────────────────────────────
class RemappedSubset(torch.utils.data.Dataset):
    def __init__(self, base_ds, indices, transform, label_map):
        self.base_ds = base_ds
        self.indices = indices
        self.transform = transform
        self.label_map = label_map

    def __len__(self):
        return len(self.indices)

    def __getitem__(self, i):
        img, lbl = self.base_ds[self.indices[i]]
        from torchvision.transforms.functional import to_pil_image
        return self.transform(to_pil_image(img)), self.label_map[lbl]


# ── 6. Dataloadery ───────────────────────────────────────────
def build_dataloaders(use_augmentation=False):
    set_seed(42)
    print("Načítavam dataset...")

    raw_train = datasets.Food101(root=DATA_ROOT, split="train",
                                 download=True, transform=transforms.ToTensor())
    raw_test = datasets.Food101(root=DATA_ROOT, split="test",
                                download=True, transform=transforms.ToTensor())

    all_classes = raw_train.classes
    selected_old_idx = {all_classes.index(c): i for i, c in enumerate(SELECTED_CLASSES)}

    def filter_indices(ds):
        return [i for i, lbl in enumerate(ds._labels) if lbl in selected_old_idx]

    train_idx = filter_indices(raw_train)
    test_idx = filter_indices(raw_test)

    train_idx, val_idx = train_test_split(
        train_idx, test_size=VAL_SPLIT, random_state=42,
        stratify=[raw_train._labels[i] for i in train_idx]
    )

    tr_tf = transform_aug if use_augmentation else transform_base
    train_ds = RemappedSubset(raw_train, train_idx, tr_tf, selected_old_idx)
    val_ds = RemappedSubset(raw_train, val_idx, transform_base, selected_old_idx)
    test_ds = RemappedSubset(raw_test, test_idx, transform_base, selected_old_idx)

    # 🔥 OPTIMALIZÁCIA 2: persistent_workers a prefetch
    kw = dict(
        batch_size=BATCH_SIZE,
        num_workers=4,
        pin_memory=True,
        persistent_workers=True,
        prefetch_factor=2
    )

    train_loader = DataLoader(train_ds, shuffle=True, **kw)
    val_loader = DataLoader(val_ds, shuffle=False, **kw)
    test_loader = DataLoader(test_ds, shuffle=False, **kw)

    print(f"✓ Train: {len(train_ds)} | Val: {len(val_ds)} | Test: {len(test_ds)}")
    return train_loader, val_loader, test_loader


# ── 7. Modely ────────────────────────────────────────────────
def build_model(arch, pretrained):
    if arch == "alexnet":
        w = tv_models.AlexNet_Weights.IMAGENET1K_V1 if pretrained else None
        m = tv_models.alexnet(weights=w)

        # ZMRAZENIE VRSTIEV (FEATURE EXTRACTION)
        if pretrained:
            for param in m.parameters():
                param.requires_grad = False

        # Nová vrstva má automaticky requires_grad = True
        m.classifier[6] = nn.Linear(m.classifier[6].in_features, NUM_CLASSES)

    elif arch == "resnet18":
        w = tv_models.ResNet18_Weights.IMAGENET1K_V1 if pretrained else None
        m = tv_models.resnet18(weights=w)

        if pretrained:
            for param in m.parameters():
                param.requires_grad = False

        m.fc = nn.Linear(m.fc.in_features, NUM_CLASSES)

    elif arch == "mobilenet_v2":
        w = tv_models.MobileNet_V2_Weights.IMAGENET1K_V1 if pretrained else None
        m = tv_models.mobilenet_v2(weights=w)

        if pretrained:
            for param in m.parameters():
                param.requires_grad = False

        m.classifier[1] = nn.Linear(m.classifier[1].in_features, NUM_CLASSES)

    return m


# ── 8. Trénovanie ────────────────────────────────────────────
def train_one_epoch(model, loader, criterion, optimizer, epoch, scaler):
    model.train()
    total_loss, correct, total = 0.0, 0, 0

    pbar = tqdm(loader, desc=f"  Train Ep {epoch}/{EPOCHS}", leave=False, dynamic_ncols=True)

    for imgs, labels in pbar:
        imgs, labels = imgs.to(DEVICE), labels.to(DEVICE)
        optimizer.zero_grad()

        with torch.amp.autocast(device_type="cuda"):
            out = model(imgs)
            loss = criterion(out, labels)

        scaler.scale(loss).backward()
        scaler.step(optimizer)
        scaler.update()

        total_loss += loss.item() * imgs.size(0)
        correct += (out.argmax(1) == labels).sum().item()
        total += imgs.size(0)

        pbar.set_postfix({"loss": f"{loss.item():.4f}", "acc": f"{100.0 * correct / total:.1f}%"})

    return total_loss / total, 100.0 * correct / total


def evaluate(model, loader, criterion, desc="  Val/Test"):
    model.eval()
    total_loss, correct, total = 0.0, 0, 0

    pbar = tqdm(loader, desc=desc, leave=False, dynamic_ncols=True)

    with torch.no_grad():
        for imgs, labels in pbar:
            imgs, labels = imgs.to(DEVICE), labels.to(DEVICE)

            with torch.amp.autocast(device_type="cuda"):
                out = model(imgs)
                loss = criterion(out, labels)

            total_loss += loss.item() * imgs.size(0)
            correct += (out.argmax(1) == labels).sum().item()
            total += imgs.size(0)

    return total_loss / total, 100.0 * correct / total


def train_model(model, train_loader, val_loader, test_loader):
    model = model.to(DEVICE)
    criterion = nn.CrossEntropyLoss()

    # ÚPRAVA OPTIMIZÉRA: Vyberie iba parametre, ktoré NIE SÚ zmrazené
    params_to_update = [p for p in model.parameters() if p.requires_grad]
    optimizer = optim.Adam(params_to_update, lr=LR, weight_decay=1e-4)

    scheduler = optim.lr_scheduler.StepLR(optimizer, step_size=7, gamma=0.1)

    scaler = torch.amp.GradScaler("cuda")

    history = {"train_loss": [], "train_acc": [], "val_loss": [], "val_acc": []}
    best_val = 0.0
    best_w = None

    for epoch in range(1, EPOCHS + 1):
        t_loss, t_acc = train_one_epoch(model, train_loader, criterion, optimizer, epoch, scaler)
        v_loss, v_acc = evaluate(model, val_loader, criterion, desc=f"  Val Ep {epoch}/{EPOCHS}")
        scheduler.step()

        history["train_loss"].append(t_loss)
        history["train_acc"].append(t_acc)
        history["val_loss"].append(v_loss)
        history["val_acc"].append(v_acc)

        if v_acc > best_val:
            best_val = v_acc
            best_w = copy.deepcopy(model.state_dict())

        print(f"  Ep {epoch:>2}/{EPOCHS} | "
              f"train loss={t_loss:.4f} acc={t_acc:.1f}% | "
              f"val loss={v_loss:.4f} acc={v_acc:.1f}%")

    model.load_state_dict(best_w)
    test_loss, test_acc = evaluate(model, test_loader, criterion, desc="  Testovanie")
    print(f"  ✓ Test: loss={test_loss:.4f}  acc={test_acc:.1f}%")
    return model, history, test_loss, test_acc


# ── 9. Experiment ────────────────────────────────────────────
def run_experiment(arch, pretrained, train_loader, val_loader, test_loader, label=""):
    mode = "TL" if pretrained else "Scratch"
    print(f"\n{'=' * 60}")
    print(f"  {label} | Arch: {arch} | Režim: {mode} | Epochy: {EPOCHS} | LR: {LR}")
    print(f"{'=' * 60}")
    results = []
    for run in range(1, NUM_RUNS + 1):
        print(f"\n  ── Beh {run}/{NUM_RUNS} ──")
        set_seed(run * 10)
        model = build_model(arch, pretrained)
        trained, history, tl, ta = train_model(model, train_loader, val_loader, test_loader)
        results.append({"run": run, "history": history,
                        "test_loss": tl, "test_acc": ta, "model": trained})
    return results


def summarize(results, label):
    accs = [r["test_acc"] for r in results]
    losses = [r["test_loss"] for r in results]
    print(f"\n  [{label}] acc: min={min(accs):.1f}% avg={np.mean(accs):.1f}% max={max(accs):.1f}%")
    print(f"  [{label}] loss: min={min(losses):.4f} avg={np.mean(losses):.4f} max={max(losses):.4f}")
    return np.mean(losses), np.mean(accs)


# ── 10. Grafy ─────────────────────────────────────────────────
def plot_history(history, title):
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 4))
    ep = range(1, len(history["train_loss"]) + 1)
    ax1.plot(ep, history["train_loss"], label="Train")
    ax1.plot(ep, history["val_loss"], label="Val")
    ax1.set_xlabel("Epocha");
    ax1.set_ylabel("Loss")
    ax1.set_title(f"{title} – Loss");
    ax1.legend();
    ax1.grid(True)
    ax2.plot(ep, history["train_acc"], label="Train")
    ax2.plot(ep, history["val_acc"], label="Val")
    ax2.set_xlabel("Epocha");
    ax2.set_ylabel("Presnosť [%]")
    ax2.set_title(f"{title} – Accuracy");
    ax2.legend();
    ax2.grid(True)
    plt.tight_layout()
    fname = title.replace(" ", "_").replace("|", "").replace("/", "") + ".png"
    plt.savefig(fname, dpi=100);
    plt.close()


def plot_scratch_vs_tl(res_s, res_tl, arch):
    bs = max(res_s, key=lambda r: r["test_acc"])
    bt = max(res_tl, key=lambda r: r["test_acc"])
    fig, axes = plt.subplots(1, 2, figsize=(13, 4))
    ep = range(1, len(bs["history"]["train_loss"]) + 1)
    for ax, key, ylabel in zip(axes, ["loss", "acc"], ["Loss", "Presnosť [%]"]):
        ax.plot(ep, bs["history"][f"train_{key}"], "b--", label="Scratch train")
        ax.plot(ep, bs["history"][f"val_{key}"], "b-", label="Scratch val")
        ax.plot(ep, bt["history"][f"train_{key}"], "r--", label="TL train")
        ax.plot(ep, bt["history"][f"val_{key}"], "r-", label="TL val")
        ax.set_xlabel("Epocha");
        ax.set_ylabel(ylabel)
        ax.set_title(f"{arch} – {ylabel}: Scratch vs TL")
        ax.legend();
        ax.grid(True)
    plt.tight_layout()
    plt.savefig(f"{arch}_scratch_vs_tl.png", dpi=100);
    plt.close()


def plot_aug_comparison(res_no_aug, res_aug, arch):
    bn = max(res_no_aug, key=lambda r: r["test_acc"])
    ba = max(res_aug, key=lambda r: r["test_acc"])
    fig, axes = plt.subplots(1, 2, figsize=(13, 4))
    ep = range(1, len(bn["history"]["train_loss"]) + 1)
    for ax, key, ylabel in zip(axes, ["loss", "acc"], ["Loss", "Presnosť [%]"]):
        ax.plot(ep, bn["history"][f"val_{key}"], "b-", label="Val bez aug")
        ax.plot(ep, ba["history"][f"val_{key}"], "r-", label="Val s aug")
        ax.set_xlabel("Epocha");
        ax.set_ylabel(ylabel)
        ax.set_title(f"{arch} – {ylabel}: bez aug vs s aug")
        ax.legend();
        ax.grid(True)
    plt.tight_layout()
    plt.savefig(f"{arch}_aug_comparison.png", dpi=100);
    plt.close()


def show_predictions(model, loader, n=8):
    model.eval()
    imgs_s, lbls_s, preds_s = [], [], []
    with torch.no_grad():
        for imgs, labels in loader:
            out = model(imgs.to(DEVICE))
            preds = out.argmax(1).cpu()
            imgs_s.extend(imgs[:n]);
            lbls_s.extend(labels[:n]);
            preds_s.extend(preds[:n])
            if len(imgs_s) >= n: break
    inv = transforms.Normalize(mean=[-m / s for m, s in zip(MEAN, STD)], std=[1 / s for s in STD])
    fig, axes = plt.subplots(2, 4, figsize=(14, 7))
    for ax, img, lbl, pred in zip(axes.flat, imgs_s, lbls_s, preds_s):
        img = inv(img).permute(1, 2, 0).clamp(0, 1).numpy()
        color = "green" if lbl == pred else "red"
        ax.imshow(img)
        ax.set_title(f"True: {SELECTED_CLASSES[lbl]}\nPred: {SELECTED_CLASSES[pred]}", color=color, fontsize=8)
        ax.axis("off")
    plt.suptitle("Ukážky predikcií  (zelená=správne, červená=chyba)")
    plt.tight_layout();
    plt.savefig("predikcie.png", dpi=100);
    plt.close()


# ── 11. HLAVNÝ BEH A TABUĽKY ──────────────────────────────────
if __name__ == "__main__":
    train_loader, val_loader, test_loader = build_dataloaders(use_augmentation=False)

    # M1 – AlexNet (Zmenené z VGG16)
    m1_s = run_experiment("alexnet", False, train_loader, val_loader, test_loader, label="M1 AlexNet")
    m1_t = run_experiment("alexnet", True, train_loader, val_loader, test_loader, label="M1 AlexNet")
    m1_sl, m1_sa = summarize(m1_s, "M1 AlexNet Scratch")
    m1_tl, m1_ta = summarize(m1_t, "M1 AlexNet TL")
    plot_scratch_vs_tl(m1_s, m1_t, "M1_AlexNet")
    plot_history(max(m1_s, key=lambda r: r["test_acc"])["history"], "M1 AlexNet Scratch najlepsi")
    plot_history(max(m1_t, key=lambda r: r["test_acc"])["history"], "M1 AlexNet TL najlepsi")

    # M2 – ResNet18
    m2_s = run_experiment("resnet18", False, train_loader, val_loader, test_loader, label="M2 ResNet18")
    m2_t = run_experiment("resnet18", True, train_loader, val_loader, test_loader, label="M2 ResNet18")
    m2_sl, m2_sa = summarize(m2_s, "M2 ResNet18 Scratch")
    m2_tl, m2_ta = summarize(m2_t, "M2 ResNet18 TL")
    plot_scratch_vs_tl(m2_s, m2_t, "M2_ResNet18")
    plot_history(max(m2_s, key=lambda r: r["test_acc"])["history"], "M2 ResNet18 Scratch najlepsi")
    plot_history(max(m2_t, key=lambda r: r["test_acc"])["history"], "M2 ResNet18 TL najlepsi")

    # M3 – MobileNetV2
    m3_s = run_experiment("mobilenet_v2", False, train_loader, val_loader, test_loader, label="M3 MobileNetV2")
    m3_t = run_experiment("mobilenet_v2", True, train_loader, val_loader, test_loader, label="M3 MobileNetV2")
    m3_sl, m3_sa = summarize(m3_s, "M3 MobileNetV2 Scratch")
    m3_tl, m3_ta = summarize(m3_t, "M3 MobileNetV2 TL")
    plot_scratch_vs_tl(m3_s, m3_t, "M3_MobileNetV2")
    plot_history(max(m3_s, key=lambda r: r["test_acc"])["history"], "M3 MobileNetV2 Scratch najlepsi")
    plot_history(max(m3_t, key=lambda r: r["test_acc"])["history"], "M3 MobileNetV2 TL najlepsi")

    # Augmentácia na najlepšom modeli
    tl_avgs = {"alexnet": m1_ta, "resnet18": m2_ta, "mobilenet_v2": m3_ta}
    best_arch = max(tl_avgs, key=tl_avgs.get)
    best_no_aug = {"alexnet": m1_t, "resnet18": m2_t, "mobilenet_v2": m3_t}[best_arch]
    print(f"\n✓ Najlepší model: {best_arch.upper()} (avg TL acc={tl_avgs[best_arch]:.1f}%)")

    train_aug, val_aug, test_aug = build_dataloaders(use_augmentation=True)
    m_aug = run_experiment(best_arch, True, train_aug, val_aug, test_aug,
                           label=f"{best_arch.upper()} TL+Aug")
    aug_l, aug_a = summarize(m_aug, f"{best_arch.upper()} TL+Aug")
    plot_aug_comparison(best_no_aug, m_aug, best_arch)
    show_predictions(max(m_aug, key=lambda r: r["test_acc"])["model"], test_aug)

    # Vypis tabuliek do konzoly
    sep = "=" * 70
    print(f"\n\n{sep}\nTABUĽKA 1 – Modely a hyperparametre\n{sep}")
    print(f"{'Model':<6} {'Architektúra':<15} {'Epochy':<8} {'LR':<8} {'Batch':<8} {'Val split'}")
    for m, a in [("M1", "AlexNet"), ("M2", "ResNet18"), ("M3", "MobileNetV2")]:
        print(f"{m:<6} {a:<15} {EPOCHS:<8} {LR:<8} {BATCH_SIZE:<8} {VAL_SPLIT}")


    def print_runs_table(results, label):
        print(f"\n{sep}\nTABUĽKA – {label}\n{sep}")
        print(
            f"{'Beh':<5} {'Train loss':>11} {'Train acc':>10} {'Val loss':>9} {'Val acc':>9} {'Test loss':>10} {'Test acc':>9}")
        for r in results:
            h = r["history"]
            print(f"{r['run']:<5} {h['train_loss'][-1]:>11.4f} {h['train_acc'][-1]:>9.1f}% "
                  f"{h['val_loss'][-1]:>9.4f} {h['val_acc'][-1]:>8.1f}% "
                  f"{r['test_loss']:>10.4f} {r['test_acc']:>8.1f}%")


    for results, label in [
        (m1_s, "M1 AlexNet Scratch"), (m1_t, "M1 AlexNet TL"),
        (m2_s, "M2 ResNet18 Scratch"), (m2_t, "M2 ResNet18 TL"),
        (m3_s, "M3 MobileNetV2 Scratch"), (m3_t, "M3 MobileNetV2 TL"),
        (m_aug, f"{best_arch.upper()} TL+Augmentacia"),
    ]:
        print_runs_table(results, label)

    print(f"\n{sep}\nTABUĽKA 5&6 – Súhrnné porovnanie\n{sep}")
    print(
        f"{'Model':<6} {'Arch':<14} {'Scr loss':>9} {'Scr acc':>8} {'>=90%':>6} {'TL loss':>9} {'TL acc':>8} {'>=93%':>6}")
    for m, arch, sl, sa, tl, ta in [
        ("M1", "AlexNet", m1_sl, m1_sa, m1_tl, m1_ta),
        ("M2", "ResNet18", m2_sl, m2_sa, m2_tl, m2_ta),
        ("M3", "MobileNetV2", m3_sl, m3_sa, m3_tl, m3_ta),
    ]:
        print(f"{m:<6} {arch:<14} {sl:>9.4f} {sa:>7.1f}% {'ano' if sa >= 90 else 'nie':>6} "
              f"{tl:>9.4f} {ta:>7.1f}% {'ano' if ta >= 93 else 'nie':>6}")

    no_aug_r = {"alexnet": m1_t, "resnet18": m2_t, "mobilenet_v2": m3_t}[best_arch]
    nvl = np.mean([r["history"]["val_loss"][-1] for r in no_aug_r])
    nva = np.mean([r["history"]["val_acc"][-1] for r in no_aug_r])
    ntl = np.mean([r["test_loss"] for r in no_aug_r])
    nta = np.mean([r["test_acc"] for r in no_aug_r])
    avl = np.mean([r["history"]["val_loss"][-1] for r in m_aug])
    ava = np.mean([r["history"]["val_acc"][-1] for r in m_aug])
    atl = np.mean([r["test_loss"] for r in m_aug])
    ata = np.mean([r["test_acc"] for r in m_aug])

    print(f"\n{sep}\nTABUĽKA 8 – {best_arch.upper()} bez aug vs s aug\n{sep}")
    print(f"{'Varianta':<20} {'Val loss':>9} {'Val acc':>9} {'Test loss':>10} {'Test acc':>9}")
    print(f"{'bez augmentacie':<20} {nvl:>9.4f} {nva:>8.1f}% {ntl:>10.4f} {nta:>8.1f}%")
    print(f"{'s augmentaciou':<20} {avl:>9.4f} {ava:>8.1f}% {atl:>10.4f} {ata:>8.1f}%")

    print(f"\n{'=' * 60}\n✓ VŠETKY EXPERIMENTY DOKONČENÉ\n{'=' * 60}")