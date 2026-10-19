import 'dart:async';
import 'package:flutter/material.dart';
import '../data/course.dart';
import '../data/course_repository.dart';
import '../state/catalog_controller.dart';
import '../state/detail_controller.dart';

class AcademyApp extends StatelessWidget {
  const AcademyApp({super.key, required this.repository});
  final CourseRepository repository;
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'My Communication Academy',
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F766E)),
      scaffoldBackgroundColor: const Color(0xFFF6F8FA),
      appBarTheme: const AppBarTheme(backgroundColor: Color(0xFFF6F8FA)),
      textTheme: ThemeData.light().textTheme.apply(
        bodyColor: const Color(0xFF172B4D),
        displayColor: const Color(0xFF172B4D),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE4E9EE)),
        ),
      ),
    ),
    home: CatalogPage(repository: repository),
  );
}

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key, required this.repository});
  final CourseRepository repository;
  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  late final CatalogController controller;
  final search = TextEditingController();
  int reportedFailures = 0;
  @override
  void initState() {
    super.initState();
    controller = CatalogController(widget.repository)..addListener(_changed);
    unawaited(controller.load());
  }

  void _changed() {
    if (controller.refreshFailures > reportedFailures) {
      reportedFailures = controller.refreshFailures;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Could not refresh. Your previous courses are still here.',
              ),
            ),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    controller.removeListener(_changed);
    controller.dispose();
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'My Communication Academy',
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
      ),
    ),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListenableBuilder(
            listenable: controller,
            builder: (context, _) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Build your next skill.',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      const Text('Practical learning for curious engineers.'),
                      const SizedBox(height: 20),
                      TextField(
                        controller: search,
                        onChanged: controller.setQuery,
                        decoration: InputDecoration(
                          hintText: 'Search courses',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: search.text.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: 'Clear search',
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    search.clear();
                                    controller.setQuery('', immediate: true);
                                  },
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (final value in <String?>[null, ...categories])
                              Padding(
                                padding: const EdgeInsetsDirectional.only(
                                  end: 8,
                                ),
                                child: ChoiceChip(
                                  label: Text(categoryLabel(value)),
                                  selected: controller.category == value,
                                  onSelected: (_) =>
                                      controller.setCategory(value),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (controller.refreshing)
                  const LinearProgressIndicator(minHeight: 2),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => controller.load(refresh: true),
                    child: CustomScrollView(
                      key: const PageStorageKey('catalog'),
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        if (controller.state == LoadState.loading)
                          const SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (controller.state == LoadState.error)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: StatusPanel(
                              icon: Icons.cloud_off_outlined,
                              title: 'Courses could not load',
                              message: 'Please try again in a moment.',
                              action: 'Try again',
                              onAction: controller.load,
                            ),
                          )
                        else if (controller.courses.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: StatusPanel(
                              icon: Icons.search_off,
                              title: 'No courses found',
                              message: 'Try another search or category.',
                              action: 'Clear filters',
                              onAction: () {
                                search.clear();
                                controller.clear();
                              },
                            ),
                          )
                        else ...[
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                            sliver: SliverToBoxAdapter(
                              child: Text(
                                '${controller.courses.length} courses',
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            sliver: SliverList.builder(
                              itemCount: controller.courses.length,
                              itemBuilder: (context, index) {
                                final course = controller.courses[index];
                                return CourseCard(
                                  course: course,
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => DetailPage(
                                        repository: widget.repository,
                                        course: course,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

String categoryLabel(String? value) => switch (value) {
  null => 'All',
  'telecom' => 'Telecom',
  'programming' => 'Programming',
  'ai' => 'AI',
  'data' => 'Data',
  _ => 'Other',
};
String minutes(int? value) =>
    value == null ? 'Duration unavailable' : '$value min';
String seconds(int value) => value % 60 == 0
    ? '${value ~/ 60} min'
    : '${value ~/ 60} min ${value % 60} sec';

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
  Widget build(BuildContext context) => Card(
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
                Tag(categoryLabel(course.category ?? 'other')),
                Tag(course.level ?? 'Unspecified'),
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
                Text(minutes(course.durationMinutes)),
                Text(
                  course.rating == null
                      ? 'Rating unavailable'
                      : '★ ${course.rating!.toStringAsFixed(1)} / 5',
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              course.price == 0
                  ? 'Free'
                  : course.price == null
                  ? 'Price unavailable'
                  : '\$${course.price!.toStringAsFixed(2)}',
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
              loadingBuilder: (_, child, progress) =>
                  progress == null ? child : placeholder,
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
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
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
  );
}

class DetailPage extends StatefulWidget {
  const DetailPage({super.key, required this.repository, required this.course});
  final CourseRepository repository;
  final Course course;
  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late final controller = DetailController(widget.repository, widget.course.id);
  @override
  void initState() {
    super.initState();
    unawaited(controller.load());
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Course details')),
    body: DetailBody(controller: controller),
  );
}

class DetailBody extends StatelessWidget {
  const DetailBody({super.key, required this.controller});
  final DetailController controller;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      if (controller.state == LoadState.loading) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.state == LoadState.error) {
        final missing = controller.failure == FailureKind.unavailable;
        return StatusPanel(
          icon: missing ? Icons.school_outlined : Icons.cloud_off_outlined,
          title: missing
              ? 'Course no longer available'
              : 'Could not load this course',
          message: missing
              ? 'This course may have been removed from the academy.'
              : 'There is a temporary problem. Please try again.',
          action: missing ? null : 'Try again',
          onAction: controller.load,
        );
      }
      final detail = controller.detail!;
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            detail.title,
            textDirection: TextDirection.ltr,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          Text(detail.instructor ?? 'Instructor unavailable'),
          const SizedBox(height: 16),
          Text(
            detail.description ?? 'No description available.',
            textDirection: TextDirection.ltr,
            style: const TextStyle(height: 1.6),
          ),
          const SizedBox(height: 24),
          Text(
            detail.lessons.isEmpty
                ? 'Duration unavailable'
                : detail.unknownDurations > 0
                ? '${seconds(detail.knownSeconds)} known · ${detail.unknownDurations} lesson duration(s) unavailable'
                : '${seconds(detail.knownSeconds)} total',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),
          Text('Course lessons', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (detail.lessons.isEmpty)
            const StatusPanel(
              icon: Icons.menu_book_outlined,
              title: 'No lessons available yet',
              message: 'Please check back later.',
            ),
          for (final lesson in detail.lessons)
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
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
                  lesson.title ?? 'Lesson ${lesson.position}',
                  textDirection: TextDirection.ltr,
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '${lesson.durationSeconds == null ? 'Duration unavailable' : seconds(lesson.durationSeconds!)} · ${lesson.isPreview
                        ? 'Preview'
                        : detail.enrolled
                        ? 'Available'
                        : 'Locked'}',
                  ),
                ),
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      detail.canOpen(lesson)
                          ? 'Playing: ${lesson.title ?? 'Lesson ${lesson.position}'}'
                          : 'Enroll in this course to access this lesson.',
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );
}
