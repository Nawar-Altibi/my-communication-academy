import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import '../data/course.dart';
import '../state/catalog_controller.dart';
import '../state/detail_controller.dart';
import 'course_widgets.dart';
import 'detail_body.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key, required this.controller});
  final CatalogController controller;
  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final search = TextEditingController();
  final scroll = ScrollController();
  DetailController? selected;
  int reportedFailures = 0;
  String _lastQuery = '';
  String? _lastCategory;
  CatalogController get controller => widget.controller;
  @override
  void initState() {
    super.initState();
    controller.addListener(_changed);
    search.text = controller.query;
  }

  void _changed() {
    if (search.text != controller.query) {
      search.value = TextEditingValue(
        text: controller.query,
        selection: TextSelection.collapsed(offset: controller.query.length),
      );
    }
    final criteriaChanged =
        _lastQuery != controller.query || _lastCategory != controller.category;
    _lastQuery = controller.query;
    _lastCategory = controller.category;
    if (criteriaChanged && scroll.hasClients) scroll.jumpTo(0);
    if (criteriaChanged ||
        (selected != null &&
            controller.state == LoadState.loaded &&
            !controller.courses.any((c) => c.id == selected!.id))) {
      _close();
    }
    if (controller.refreshFailures > reportedFailures) {
      reportedFailures = controller.refreshFailures;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(context.t.refreshError)));
        }
      });
    }
  }

  void _close() {
    if (selected == null) return;
    final old = selected;
    setState(() => selected = null);
    old?.dispose();
  }

  void _open(Course course) {
    FocusScope.of(context).unfocus();
    if (selected?.id == course.id) return;
    selected?.dispose();
    setState(
      () => selected = DetailController(controller.repository, course.id),
    );
    unawaited(selected!.load());
  }

  @override
  void dispose() {
    controller.removeListener(_changed);
    selected?.dispose();
    search.dispose();
    scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 840;
        return PopScope(
          canPop: selected == null,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _close();
          },
          child: Scaffold(
            appBar: AppBar(
              toolbarHeight:
                  56 * MediaQuery.textScalerOf(context).scale(1).clamp(1, 1.5),
              leading: !wide && selected != null
                  ? IconButton(
                      tooltip: context.t.back,
                      onPressed: _close,
                      icon: const Icon(Icons.arrow_back),
                    )
                  : null,
              title: _AppTitle(
                text: !wide && selected != null
                    ? context.t.details
                    : context.t.academy,
                showLogo: wide || selected == null,
              ),
              actions: [
                _LanguageButton(
                  onPressed: () => controller.setLanguage(
                    controller.language == 'en' ? 'ar' : 'en',
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
            body: SafeArea(
              child: wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          width: (constraints.maxWidth * .4).clamp(320, 420),
                          child: _catalog(context),
                        ),
                        const VerticalDivider(width: 1),
                        Expanded(
                          child: selected == null
                              ? StatusPanel(
                                  icon: Icons.auto_stories_outlined,
                                  title: context.t.chooseTitle,
                                  message: context.t.chooseMessage,
                                )
                              : DetailBody(controller: selected!),
                        ),
                      ],
                    )
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        Offstage(
                          offstage: selected != null,
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 760),
                              child: _catalog(context),
                            ),
                          ),
                        ),
                        if (selected != null)
                          Positioned.fill(
                            child: DetailBody(controller: selected!),
                          ),
                      ],
                    ),
            ),
          ),
        );
      },
    ),
  );

  Widget _catalog(BuildContext context) => RefreshIndicator(
    onRefresh: () => controller.load(refresh: true),
    child: CustomScrollView(
      controller: scroll,
      key: const PageStorageKey('catalog'),
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    context.t.headline,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(context.t.intro),
                const SizedBox(height: 20),
                TextField(
                  controller: search,
                  onChanged: controller.setQuery,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => controller.load(),
                  decoration: InputDecoration(
                    labelText: context.t.search,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: search.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: context.t.clearSearch,
                            icon: const Icon(Icons.close),
                            onPressed: () =>
                                controller.setQuery('', immediate: true),
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
                          padding: const EdgeInsetsDirectional.only(end: 8),
                          child: ChoiceChip(
                            materialTapTargetSize: MaterialTapTargetSize.padded,
                            label: Text(categoryLabel(context, value)),
                            selected: controller.category == value,
                            onSelected: (_) => controller.setCategory(value),
                          ),
                        ),
                    ],
                  ),
                ),
                if (controller.showingSaved)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      context.t.savedCatalog(
                        DateFormat.yMd(
                          controller.language,
                        ).add_Hm().format(controller.savedAt!.toLocal()),
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (controller.refreshing)
          const SliverToBoxAdapter(
            child: LinearProgressIndicator(minHeight: 2),
          ),
        if (controller.state == LoadState.loading)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: CircularProgressIndicator(
                semanticsLabel: context.t.loading,
              ),
            ),
          )
        else if (controller.state == LoadState.error)
          SliverFillRemaining(
            hasScrollBody: false,
            child: StatusPanel(
              icon: Icons.cloud_off_outlined,
              title: context.t.catalogError,
              message: context.t.tryLater,
              action: context.t.retry,
              onAction: controller.load,
            ),
          )
        else if (controller.courses.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: StatusPanel(
              icon: Icons.search_off,
              title: context.t.emptyTitle,
              message: context.t.emptyMessage,
              action: context.t.clearFilters,
              onAction: controller.clear,
            ),
          )
        else ...[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            sliver: SliverToBoxAdapter(
              child: Semantics(
                liveRegion: true,
                child: Text(
                  context.t.courseCount(controller.courses.length),
                  style: Theme.of(context).textTheme.labelLarge,
                ),
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
                  selected: selected?.id == course.id,
                  onTap: () => _open(course),
                );
              },
            ),
          ),
        ],
      ],
    ),
  );
}

class _AppTitle extends StatelessWidget {
  const _AppTitle({required this.text, required this.showLogo});
  final String text;
  final bool showLogo;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        if (showLogo) ...[
          ExcludeSemantics(
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.cell_tower_rounded,
                size: 20,
                color: colors.onPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Flexible(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _LanguageButton extends StatelessWidget {
  const _LanguageButton({required this.onPressed});
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => Tooltip(
    message: context.t.switchLanguage,
    child: FilledButton.tonalIcon(
      onPressed: onPressed,
      icon: const Icon(Icons.translate_rounded, size: 18),
      label: Text(
        context.t.language,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 14),
      ),
    ),
  );
}
