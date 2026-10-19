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
          Tag(t.details),
          const SizedBox(height: 16),
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
          Text(
            detail.instructor ?? t.instructorUnavailable,
            textDirection: detail.instructor == null ? null : TextDirection.ltr,
          ),
          const SizedBox(height: 16),
          Text(
            detail.description ?? t.descriptionUnavailable,
            textDirection: detail.description == null
                ? null
                : TextDirection.ltr,
            style: const TextStyle(height: 1.6),
          ),
          const SizedBox(height: 24),
          Text(
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
          const SizedBox(height: 24),
          Semantics(
            header: true,
            child: Text(
              t.lessons,
              style: Theme.of(context).textTheme.titleLarge,
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
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Semantics(
                    button: true,
                    label: '$title, $access, $duration',
                    excludeSemantics: true,
                    onTap: () => _play(context, detail.canOpen(lesson), title),
                    child: ListTile(
                      minVerticalPadding: 16,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      leading: Icon(
                        detail.canOpen(lesson)
                            ? Icons.play_circle_outline
                            : Icons.lock_outline,
                      ),
                      title: Text(
                        title,
                        textDirection: lesson.title == null
                            ? null
                            : TextDirection.ltr,
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text('$duration · $access'),
                      ),
                      onTap: () =>
                          _play(context, detail.canOpen(lesson), title),
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
