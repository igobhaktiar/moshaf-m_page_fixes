import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/core/data_sources/juz_fihris.dart';
import 'package:qeraat_moshaf_kwait/core/utils/number_to_arabic.dart';
import 'package:qeraat_moshaf_kwait/core/widgets/app_button.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';

class PageNavigatorDialog extends StatefulWidget {
  final int currentPage;
  final int totalPages;

  const PageNavigatorDialog({
    Key? key,
    required this.currentPage,
    this.totalPages = 604,
  }) : super(key: key);

  @override
  State<PageNavigatorDialog> createState() => _PageNavigatorDialogState();
}

class _PageNavigatorDialogState extends State<PageNavigatorDialog>
    with SingleTickerProviderStateMixin {
  late TextEditingController _pageController;
  late int _selectedPage;
  late ScrollController _scrollController;
  late TabController _tabController;
  bool _isDirectEntry = false;

  @override
  void initState() {
    super.initState();
    _selectedPage = widget.currentPage;
    _pageController = TextEditingController(text: _selectedPage.toString());
    _scrollController = ScrollController(
      initialScrollOffset: (_selectedPage - 1) * 48.0,
    );
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _handlePageSelection(int page) {
    if (page >= 1 && page <= widget.totalPages) {
      setState(() {
        _selectedPage = page;
        if (!_isDirectEntry) {
          _pageController.text = page.toString();
        }
      });
    }
  }

  void _navigateToSelectedPage() {
    Navigator.of(context).pop();
    EssentialMoshafCubit.get(context).navigateToPage(_selectedPage);
  }

  // Get juz number from page number
  int _getJuzFromPage(int page) {
    for (int i = 0; i < ajzaaFihrisJson.length; i++) {
      if (page >= ajzaaFihrisJson[i]['page_start'] &&
          page <= ajzaaFihrisJson[i]['page_end']) {
        return ajzaaFihrisJson[i]['number'];
      }
    }
    return 1; // Default to first juz if not found
  }

  // Determine if UI should be in Arabic mode
  bool _isArabicUI() {
    final locale = Localizations.localeOf(context).languageCode;
    return locale == 'ar';
  }

  // Convert number to Arabic if needed
  String _formatNumber(int number) {
    if (_isArabicUI()) {
      return convertToArabicNumber(number.toString());
    }
    return number.toString();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = _isArabicUI();
    final currentJuz = _getJuzFromPage(_selectedPage);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).dialogBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.translate.navigateToPage,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Direct page entry field
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _pageController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: context.translate.enterPageNumber,
                        border: InputBorder.none,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _isDirectEntry = true;
                          if (value.isNotEmpty) {
                            int? page = int.tryParse(value);
                            if (page != null) {
                              _selectedPage = page.clamp(1, widget.totalPages);
                            }
                          }
                        });
                      },
                      onSubmitted: (_) => _navigateToSelectedPage(),
                    ),
                  ),
                  Text(
                    ' / ${_formatNumber(widget.totalPages)}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Current page and juz information
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${context.translate.currentPage}: ${_formatNumber(_selectedPage)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${context.translate.juz}: ${_formatNumber(currentJuz)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tab bar for Pages and Juz'
            TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: context.translate.pages),
                Tab(text: context.translate.juz),
              ],
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor:
                  Theme.of(context).textTheme.bodyMedium?.color,
              indicatorColor: Theme.of(context).primaryColor,
            ),

            const SizedBox(height: 16),

            // Page slider
            SliderTheme(
              data: SliderThemeData(
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
                overlayShape: RoundSliderOverlayShape(overlayRadius: 16),
                activeTrackColor: Theme.of(context).primaryColor,
                inactiveTrackColor: Theme.of(context).dividerColor,
                thumbColor: Theme.of(context).primaryColor,
                overlayColor: Theme.of(context).primaryColor.withOpacity(0.3),
              ),
              child: Slider(
                value: _selectedPage.toDouble(),
                min: 1,
                max: widget.totalPages.toDouble(),
                divisions: widget.totalPages - 1,
                label: _formatNumber(_selectedPage),
                onChanged: (value) {
                  setState(() {
                    _isDirectEntry = false;
                    _handlePageSelection(value.toInt());
                  });
                },
              ),
            ),

            const SizedBox(height: 16),

            // Tab view content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Pages Grid
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    child: GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        childAspectRatio: 1.2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: widget.totalPages,
                      itemBuilder: (context, index) {
                        final page = index + 1;
                        final isSelected = page == _selectedPage;

                        return Material(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(8),
                          elevation: isSelected ? 4 : 0,
                          child: InkWell(
                            onTap: () => _handlePageSelection(page),
                            borderRadius: BorderRadius.circular(8),
                            child: Center(
                              child: Text(
                                _formatNumber(page),
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Juz Grid
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: ajzaaFihrisJson.length,
                      itemBuilder: (context, index) {
                        final juz = ajzaaFihrisJson[index];
                        final juzNumber = juz['number'];
                        final isCurrentJuz = juzNumber == currentJuz;

                        return Card(
                          color: isCurrentJuz
                              ? Theme.of(context).primaryColor.withOpacity(0.1)
                              : null,
                          elevation: 0,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: isCurrentJuz
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context)
                                      .dividerColor
                                      .withOpacity(0.5),
                              width: isCurrentJuz ? 2 : 1,
                            ),
                          ),
                          child: InkWell(
                            onTap: () =>
                                _handlePageSelection(juz['page_start']),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    radius: 16,
                                    child: Text(
                                      _formatNumber(juzNumber),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isArabic
                                              ? juz['name']
                                              : "Juz' ${_formatNumber(juzNumber)}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${context.translate.pages}: ${_formatNumber(juz['page_start'])} - ${_formatNumber(juz['page_end'])}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    context.translate.cancel,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AppButton(
                  text: context.translate.goToPage,
                  height: 50,
                  textColor: context.theme.elevatedButtonTheme.style!.textStyle!
                      .resolve({})!.color,
                  color: context
                      .theme.elevatedButtonTheme.style!.backgroundColor!
                      .resolve({})!,
                  borderRadius: 15,
                  onPressed: _navigateToSelectedPage,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void showPageNavigatorDialog(BuildContext context, int currentPage) {
  showDialog(
    context: context,
    builder: (context) => PageNavigatorDialog(
      currentPage: currentPage,
      totalPages: 604,
    ),
  );
}
