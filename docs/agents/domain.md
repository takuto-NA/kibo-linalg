# Domain docs

## Before exploring

設計・実装を調査する前に、ルートの `CONTEXT.md` と対象領域に関係する `docs/adr/` のADRを読む。
これらがまだ存在しない場合は調査を続ける。用語や判断が確定した時点でdomain-modelingスキルが作成する。

## File structure

- `CONTEXT.md`: このプロジェクトの用語と意味。
- `docs/adr/`: 設計判断とその理由。連番と内容を表す名前で保存する。

このリポジトリは単一コンテキスト構成で管理する。

## Vocabulary and decisions

課題、設計、実装、テストで使う概念名は `CONTEXT.md` の定義に合わせる。
必要な概念が未定義なら、既存用語で表せるか確認し、実際の不足はdomain-modelingで扱う。
既存ADRと異なる提案をするときは、該当ADRと再検討の理由を明示する。
