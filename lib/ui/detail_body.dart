import 'package:flutter/material.dart';
import '../data/course_repository.dart';
import '../state/catalog_controller.dart';
import '../state/detail_controller.dart';
import 'course_widgets.dart';

class DetailBody extends StatelessWidget {
  const DetailBody({super.key, required this.controller});
  final DetailController controller;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final t = context.t;
      if (controller.state == LoadState.loading) {
        return Center(
          child: CircularProgressIndicator(semanticsLabel: t.loading),
        );
      }
      if (controller.state == LoadState.error) {
        final missing = controller.failure == FailureKind.unavailable;
        return StatusPanel(
          icon: missing ? Icons.school_outlined : Icons.cloud_off_outlined,
          title: missing ? t.missingTitle : t.detailError,
          message: missing ? t.missingMessage : t.temporaryMessage,
          action: missing ? null : t.retry,
          onAction: controller.load,
        );
      }
      final detail = controller.detail!;
      return ListView(
        key: PageStorageKey('detail-${detail.id}'),
        padding: const EdgeInsets.all(24),
        children: [
          Semantics(
            header: true,
            child: Text(
              detail.title,
              textDirection: TextDirection.ltr,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 16),
          _InfoRow(
            icon: Icons.person_outline,
            child: Text(
              detail.instructor ?? t.instructorUnavailable,
              textDirection: detail.instructor == null
                  ? null
                  : TextDirection.ltr,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.schedule_outlined,
            child: Text(
              detail.lessons.isEmpty
                  ? t.durationUnavailable
                  : detail.unknownDurations > 0
                  ? t.partialDuration(
                      seconds(context, detail.knownSeconds),
                      detail.unknownDurations,
                    )
                  : t.totalDuration(seconds(context, detail.knownSeconds)),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            detail.description ?? t.descriptionUnavailable,
            textDirection: detail.description == null
                ? null
                : TextDirection.ltr,
            style: TextStyle(
              height: 1.6,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 20),
          Semantics(
            header: true,
            child: Text(
              t.lessons,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 12),
          if (detail.lessons.isEmpty)
            StatusPanel(
              icon: Icons.menu_book_outlined,
              title: t.emptyLessons,
              message: t.checkBack,
            ),
          for (final lesson in detail.lessons)
            Builder(
              builder: (context) {
                final title = lesson.title ?? t.lessonNumber(lesson.position);
                final access = lesson.isPreview
                    ? t.preview
                    : detail.enrolled
                    ? t.available
                    : t.locked;
                final duration = lesson.durationSeconds == null
                    ? t.durationUnavailable
                    : seconds(context, lesson.durationSeconds!);
                final open = detail.canOpen(lesson);
                final colors = Theme.of(context).colorScheme;
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Semantics(
                    button: true,
                    label: '$title, $access, $duration',
                    excludeSemantics: true,
                    onTap: () => _play(context, open, title),
                    child: ListTile(
                      minVerticalPadding: 16,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: open
                            ? const Color(0xFFE8F2F1)
                            : colors.surfaceContainerHighest,
                        foregroundColor: open
                            ? colors.primary
                            : colors.onSurfaceVariant,
                        child: Icon(
                          open ? Icons.play_arrow_rounded : Icons.lock_outline,
                        ),
                      ),
                      title: Text(
                        title,
                        textDirection: lesson.title == null
                            ? null
                            : TextDirection.ltr,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: open ? null : colors.onSurfaceVariant,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text('$duration · $access'),
                      ),
                      onTap: () => _play(context, open, title),
                    ),
                  ),
                );
              },
            ),
        ],
      );
    },
  );

  void _play(BuildContext context, bool available, String title) =>
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(
              available ? context.t.playing(title) : context.t.lockedMessage,
            ),
          ),
        );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.child});
  final IconData icon;
  final Widget child;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
      const SizedBox(width: 10),
      Expanded(child: child),
    ],
  );
}
