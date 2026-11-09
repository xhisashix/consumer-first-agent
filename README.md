# agent-marketing-waza

**Antigravity / GitHub Copilot / Claude Code** の3環境で「Marketing Waza」の全10担当サブエージェント・スキル・オーケストレーション規約を一元管理し、**プライベートPC・会社PC・複数プロジェクト間でポータブルに使い回すための「AIエージェント版 dotfiles」リポジトリ**です。

すべてのサブエージェント・スキルは **「モードA：エンジニアリング・開発マネジメントモード」** と **「モードB：マーケティング戦略・事業推進モード」** の2モードに対応しています。

---

## 搭載サブエージェント＆スキル一覧（全10担当）

| No | 識別名 (`name`) | 担当ロール | 主な成果物 |
| :-: | :--- | :--- | :--- |
| **①** | `marketing-waza-brand-manager` | ブランドマネージャー（全体統括・WHO/WHAT/HOW戦略・エクイティ担当） | WHO / WHAT / HOW 戦略定義シート |
| **②** | `marketing-waza-cmk-researcher` | CMK / 顧客理解・リサーチ担当（3つの顔・行動×知覚・顧客我） | CMK リサーチ設計＆顧客インサイト仮説シート |
| **③** | `marketing-waza-concept-innovator` | コンセプト開発・イノベーション担当（Connecting Dots・50字アイデア・RTB） | イノベーション＆コンセプト開発シート |
| **④** | `marketing-waza-creative-director` | クリエイティブ・広告制作担当（ブリーフ・アイデア×ドラマ・SMILE評価） | クリエイティブブリーフ＆コミュニケーション評価シート |
| **⑤** | `marketing-waza-digital-pr-strategist` | デジタル・PR・インフルエンサー戦略担当（バリア打破・インフルエンサーマップ・UGC） | デジタル・PR・インフルエンサー戦略設計シート |
| **⑥** | `marketing-waza-scientific-sales` | 科学的営業・トレードマーケティング担当（4大課題・DPSM×VECTR・5ステップ話法） | 科学的営業・トレードマーケティング戦略＆商談設計シート |
| **⑦** | `marketing-waza-financial-strategist` | ファイナンシャル戦略（PL・収益管理・限界利益率・3年予測・投資ROI）担当 | ファイナンシャル戦略＆3年PL・投資回収シミュレーションシート |
| **⑧** | `marketing-waza-memo-writer-pro` | One Page Memo ライティング・添削担当（Approval型・Report型1/2・和田氏の鉄の掟） | 完成版 One Page Memo ＆ 鉄の掟セルフチェック |
| **⑨** | `marketing-waza-leadership-oneteam` | リーダーシップ・ワンチーム推進担当（26の行動原則・ジョハリの窓・権限移譲） | ワンチーム推進＆リーダーシップ行動計画シート |
| **⑩** | `marketing-waza-talent-developer` | 人材育成・スキル評価担当（スキル分解・70:20:10・KSA・OJTブリーフ・W&DP） | 人材育成スキルマップ ＆ W&DP・OJTブリーフィング設計シート |

---

## ディレクトリ構成

```text
agent-marketing-waza/
├── plugin.json                # Antigravity プラグインマニフェスト
├── AGENTS.md                  # rules/AGENTS.md へのシンボリックリンク
├── rules/
│   └── AGENTS.md              # [正本] 親エージェントのオーケストレーション・ルーティング規約
├── agents/
│   ├── _template.md           # サブエージェント追加用テンプレート
│   └── marketing-waza-*.md    # [正本] 全10担当のサブエージェント定義
├── skills/
│   ├── _template/             # スキル追加用テンプレート
│   └── marketing-waza-*/      # [正本] 全10担当のスキル定義（SKILL.md）
├── local/                     # [Git除外] 会社PC専用・個人PC専用の非公開ルール/スキル/エージェント置き場
│   ├── README.md
│   ├── rules/
│   ├── agents/
│   └── skills/
└── scripts/
    └── setup-links.sh         # 3ツールへのシンボリックリンク一括展開・管理スクリプト
```

---

## クイックスタート（プライベートPC / 会社PC での初期セットアップ）

新しいPCにリポジトリをクローンしたら、以下の1コマンドを実行するだけでPC全体（グローバル環境）にリンクが張られます。

```bash
./scripts/setup-links.sh --global
```

### `--global` でリンクされる場所
| ツール | リンク先パス |
| :--- | :--- |
| **Antigravity** | `~/.gemini/config/plugins/agent-marketing-waza` |
| **Claude Code** | `~/.claude/rules/`, `~/.claude/agents/*.md`, `~/.claude/skills/*` |
| **GitHub Copilot** | `~/.copilot/agents/*.agent.md` *(自動で拡張子変換)*, `~/.copilot/skills/*` |

---

## 便利なコマンド一覧

```bash
# 現在のエージェント・スキル一覧とリンク状態を確認
./scripts/setup-links.sh --status

# このリポジトリ自身でローカル動作テスト用に展開したい場合 (.agents, .claude, .github)
./scripts/setup-links.sh --self

# 特定の別プロジェクト（リポジトリ）内にだけローカル展開したい場合
./scripts/setup-links.sh --project /path/to/your-project

# グローバルリンクを安全に解除したい場合
./scripts/setup-links.sh --unlink-global
```
