# Issue tracker: GitHub

このリポジトリの課題と仕様はGitHub Issuesで管理する。操作には `gh` CLIを使用する。対象リポジトリは `git remote -v` から確認する。

## Conventions

- 作成: `gh issue create --title "..." --body-file <path>`。
- 本文とコメントの参照: `gh issue view <number> --comments`。ラベルや担当者が必要ならJSON出力を使用する。
- 一覧: `gh issue list --state open --json number,title,body,labels,assignees`。必要に応じて状態・ラベルで絞る。
- コメント: `gh issue comment <number> --body-file <path>`。
- 本文更新: `gh issue edit <number> --body-file <path>`。
- ラベル: `gh issue edit <number> --add-label "..."` / `--remove-label "..."`。
- クローズ: `gh issue close <number>`。

複数行の本文やコメントはUTF-8の一時ファイルに書き、`--body-file` で渡す。
課題を人に示すときはタイトルをリンクにし、番号だけで呼ばない。

## Pull requests as a triage surface

**PRs as a request surface: no.**

外部PRを要望として分類する運用に切り替える場合は、この値を `yes` に変更する。
GitHubではIssuesとPRが番号空間を共有する。参照が曖昧なら種別を確認する。

## Skill operations

- 「publish to the issue tracker」はGitHub Issueの作成を意味する。
- 「fetch the relevant ticket」は対象Issueの本文とコメントの参照を意味する。

## Wayfinding operations

- Map: `wayfinder:map` ラベルを持つ単一Issue。
- Child ticket: mapのGitHub sub-issueとしてリンクする。利用できない場合はmap内のタスクリストと子Issue先頭の `Part of #<map>` で関連付ける。
- Type: `wayfinder:research` / `wayfinder:prototype` / `wayfinder:grilling` / `wayfinder:task`。
- Blocking: GitHubのnative issue dependenciesを使用する。`gh api --method POST repos/<owner>/<repo>/issues/<child>/dependencies/blocked_by -F issue_id=<blocker-db-id>`。database IDは `gh api repos/<owner>/<repo>/issues/<number> --jq .id` で取得する。
- Dependenciesが利用できない場合は子Issue先頭の `Blocked by: #<number>, #<number>` で表す。
- Frontier: mapのopenな子Issueのうち、openなblockerも担当者もないもの。map内の順序で選ぶ。native dependencies使用時は `issue_dependencies_summary.blocked_by` を確認する。
- Claim: 作業開始前に `gh issue edit <number> --add-assignee @me`。
- Resolve: 判断をresolution commentとして記録し、Issueを閉じ、mapのDecisions so farに判断の要旨とリンクを追加する。

必要なラベルが存在しない場合は、適用前に作成する。
