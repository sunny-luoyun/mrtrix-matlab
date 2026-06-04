# Git Push 规则

推送代码时，使用 `git push origin` 而不是 `git push gitee`。
因为 `origin` remote 已配了两个 push URL（GitHub + Gitee），
`git push origin` 会同时推送到两个平台。
