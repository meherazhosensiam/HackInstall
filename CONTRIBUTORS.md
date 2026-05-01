# 🤝 Contributors

Thank you to everyone who has helped make HackInstall better!

---

## 🧑‍💻 Core Author

| Name | Role | Contact |
|---|---|---|
| **Siam** | Creator & Lead Developer | Bangladesh 🇧🇩 |

---

## 🌟 How to Contribute

We welcome contributions of all kinds:

- 🐛 **Bug reports** — Open a GitHub Issue describing the problem, your OS, and log output
- 🔧 **Tool additions** — Add new tools to the relevant category function in `hackinstall.sh`
- 🌐 **Distro support** — Help test and fix compatibility on non-Debian distros
- 📝 **Documentation** — Improve README, add examples, fix typos
- 🌍 **Translations** — Translate README to other languages (Bangla, Hindi, etc.)

---

## 📋 Contribution Guidelines

### Adding a New Tool

Find the right category function (e.g. `install_webapps()`) and add a line:

```bash
install_pkg "ToolName"  "package-name"  pkg      # apt/dnf/pacman package
install_pkg "ToolName"  "pip-name"      pip      # Python pip package
install_pkg "ToolName"  "gem-name"      gem      # Ruby gem
install_pkg "ToolName"  "go/module/path" go      # Go module
install_pkg "ToolName"  "https://github.com/user/repo.git" git "setup_command"
```

### Pull Request Checklist

- [ ] Tested on at least one supported Linux distro
- [ ] Tool is free and open-source (or has a free tier)
- [ ] Tool is relevant to ethical penetration testing / security research
- [ ] No duplicate entries
- [ ] `install_pkg` call uses the correct method (`pkg` / `pip` / `gem` / `go` / `git`)
- [ ] PR title format: `feat: add ToolName to CategoryName`

### Commit Message Format

```
feat: add <tool> to <category>
fix: handle missing go binary on Arch
docs: update wordlists section in README
chore: remove deprecated tool sqlmap2
```

---

## 🏆 Hall of Fame

> *Be the first to contribute and get your name here!*

| GitHub Handle | Contribution |
|---|---|
| *(your name here)* | *(your contribution)* |

---

## 📬 Contact

- Open a GitHub Issue for bugs or feature requests
- Submit a Pull Request for code contributions

---

*Every contribution, no matter how small, is appreciated. Happy hacking — legally!* ⚔️
