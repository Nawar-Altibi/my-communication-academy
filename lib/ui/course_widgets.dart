import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show NumberFormat;
import '../data/course.dart';
import '../l10n/app_localizations.dart';

extension Translations on BuildContext {
  L10n get t => L10n.of(this);
}

String categoryLabel(BuildContext context, String? value) => switch (value) {
  null => context.t.all,
  'telecom' => context.t.telecom,
  'programming' => context.t.programming,
  'ai' => context.t.ai,
  'data' => context.t.data,
  _ => context.t.other,
};
String levelLabel(BuildContext context, String? value) => switch (value) {
  'beginner' => context.t.beginner,
  'intermediate' => context.t.intermediate,
  'advanced' => context.t.advanced,
  _ => context.t.unspecified,
};
String seconds(BuildContext context, int value) => value % 60 == 0
    ? context.t.minuteCount(value ~/ 60)
    : context.t.secondCount(value ~/ 60, value % 60);

class CourseCard extends StatelessWidget {
  const CourseCard({
    super.key,
    required this.course,
    required this.onTap,
    this.selected = false,
  });
  final Course course;
  final VoidCallback onTap;
  final bool selected;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: context.t.openCourse(course.title),
    child: Card(
      margin: const EdgeInsets.only(bottom: 14),
      color: selected ? Theme.of(context).colorScheme.primaryContainer : null,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: AspectRatio(
                  aspectRatio: 16 / 7,
                  child: CourseImage(url: course.thumbnailUrl),
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  Tag(categoryLabel(context, course.category ?? 'other')),
                  Tag(levelLabel(context, course.level)),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                course.title,
                textDirection: TextDirection.ltr,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  Text(
                    course.durationMinutes == null
                        ? context.t.durationUnavailable
                        : context.t.minuteCount(course.durationMinutes!),
                  ),
                  Text(
                    course.rating == null
                        ? context.t.ratingUnavailable
                        : '★ ${course.rating!.toStringAsFixed(1)} / 5',
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                course.price == 0
                    ? context.t.free
                    : course.price == null
                    ? context.t.priceUnavailable
                    : NumberFormat.simpleCurrency(
                        locale: 'en_US',
                      ).format(course.price),
                textDirection: course.price != null && course.price != 0
                    ? TextDirection.ltr
                    : null,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class CourseImage extends StatelessWidget {
  const CourseImage({super.key, this.url});
  final String? url;
  @override
  Widget build(BuildContext context) {
    final placeholder = ColoredBox(
      color: const Color(0xFFE8F2F1),
      child: Center(
        child: Icon(
          Icons.school_outlined,
          size: 42,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
    return ExcludeSemantics(
      child: url == null
          ? placeholder
          : Image.network(
              url!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => placeholder,
              frameBuilder: (_, child, frame, _) =>
                  frame == null ? placeholder : child,
            ),
    );
  }
}

class Tag extends StatelessWidget {
  const Tag(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: const Color(0xFFEDF3F5),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF244454),
        ),
      ),
    ),
  );
}

class StatusPanel extends StatelessWidget {
  const StatusPanel({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.onAction,
  });
  final IconData icon;
  final String title;
  final String message;
  final String? action;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: Icon(
                icon,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 18),
            Semantics(
              header: true,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            if (action != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: FilledButton(onPressed: onAction, child: Text(action!)),
              ),
          ],
        ),
      ),
    ),
  );
}
