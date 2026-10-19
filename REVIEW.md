# Review: CourseDetailPage

| Severity | Issue and impact | Suggested fix |
| --- | --- | --- |
| critical | A credential is embedded in a client-side URL. App binaries, logs, proxies and source history expose it. | Treat the supplied token as compromised: revoke/rotate it, remove it from source/history as appropriate, and use a backend-issued user session. A privileged secret cannot be protected inside an app. Do not log tokens in URLs. |
| major | `load()` runs from `build()`. Each completion calls `setState`, which builds and starts another request; progress events also trigger requests. | Load once in `initState`; reload explicitly and in `didUpdateWidget` when the course ID changes. Keep `build` free of side effects. |
| major | Network, non-2xx and JSON errors are unchecked. Loading can remain forever, and error bodies may be parsed as courses. | Check status codes, catch transport/format failures, and represent loading, success, empty, temporary error and 404 distinctly with retry. |
| major | Requests can complete after disposal or after a newer course request. `setState` can throw or stale data can win. | Guard completion with `mounted` and a request generation/ID; cancel supported work and invalidate pending work in `dispose`. Reset state when the course changes. |
| major | The progress subscription and scroll controller are never disposed. The stream retains the page and may call `setState` after removal. | Cancel `progressSub` and dispose `scrollController` in `dispose`, then call `super.dispose()`. Filter updates to the current course; a lesson ID alone may not be globally unique. |
| major | Raw casts and force unwraps assume perfect data. Missing lessons, titles or numeric durations crash; invalid values can produce a misleading total. | Parse typed models outside the widget, validate records independently and explicitly represent unknown durations. Show an incomplete-total label when needed. |
| major | Every lesson navigates to the video regardless of enrollment or preview status, and assumes a valid video URL. | Derive access from server enrollment/preview values, explain locked lessons and validate playback data. Enforce authorization server-side too; hiding a button is insufficient. |
| major | `enroll()` declares success for rejected HTTP responses, can be tapped repeatedly, and uses context after an asynchronous gap. It pops the page rather than updating confirmed state. | Add an in-flight guard, check the response, handle failure, verify `mounted`, and update/refetch confirmed enrollment before displaying success. |
| minor | HTTP, JSON parsing, progress and presentation are tightly coupled, making important failure paths hard to test. | Inject a repository/progress dependency and move parsing/request coordination out of the widget. Test stale responses and disposal. |
| minor | Whole-minute rounding hides short durations; the loading branch lacks a consistent page shell, and the constructor omits a key/const. | Use a duration formatter that preserves meaningful seconds, keep one Scaffold across states, and use `const CourseDetailPage({super.key, required this.courseId});`. |

## Required before merge, in order

1. Revoke/rotate the exposed credential and replace client-held privileged authentication.
2. Remove requests from `build`; implement lifecycle-safe, ordered loading with status/error handling and resource cleanup.
3. Enforce lesson access and confirmed enrollment, with safe typed parsing and regression tests for malformed data.
