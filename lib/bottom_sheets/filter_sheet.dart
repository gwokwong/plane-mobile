import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:plane_startup/models/issues.dart';
import 'package:plane_startup/provider/provider_list.dart';
import 'package:plane_startup/utils/custom_toast.dart';
import 'package:plane_startup/utils/enums.dart';
import 'package:plane_startup/widgets/custom_button.dart';
import 'package:plane_startup/widgets/custom_expansion_tile.dart';

import 'package:plane_startup/widgets/custom_text.dart';

// ignore: must_be_immutable
class FilterSheet extends ConsumerStatefulWidget {
  FilterSheet(
      {super.key,
      required this.issueCategory,
      this.filtersData,
      this.fromCreateView = false});
  final Enum issueCategory;
  final bool fromCreateView;
  dynamic filtersData;
  @override
  ConsumerState<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<FilterSheet> {
  List priorities = [
    {'icon': Icons.error_outline_rounded, 'text': 'urgent','title': '紧急'},
    {'icon': Icons.signal_cellular_alt, 'text': 'high','title': '高'},
    {'icon': Icons.signal_cellular_alt_2_bar, 'text': 'medium','title': '中'},
    {'icon': Icons.signal_cellular_alt_1_bar, 'text': 'low','title': '低'},
    {'icon': Icons.do_disturb_alt_outlined, 'text': 'null','title': '无'}
  ];

  List states = [
    {'id': 'backlog', 'name': 'Backlog','title': '积压'},
    {'id': 'unstarted', 'name': 'Unstarted','title': '未开始'},
    {'id': 'started', 'name': 'Started','title': '已开始'},
    {'id': 'completed', 'name': 'Completed','title': '已完成'},
    {'id': 'cancelled', 'name': 'Cancelled','title': '已取消'}
  ];

  Filters filters = Filters(
    priorities: [],
    states: [],
    assignees: [],
    createdBy: [],
    labels: [],
    targetDate: [],
  );

  List<DateTime?> _rangeDatePickerValueWithDefaultValue = [];
  bool lastWeek = false;
  bool twoWeeks = false;
  bool oneMonth = false;
  bool twoMonths = false;
  bool customDate = false;

  datesEnabled() {
    lastWeek = filters.targetDate.contains(
            '${DateTime.now().subtract(const Duration(days: 7)).toString().split(' ')[0]};after') &&
        filters.targetDate
            .contains('${DateTime.now().toString().split(' ')[0]};before');

    twoWeeks = filters.targetDate
            .contains('${DateTime.now().toString().split(' ')[0]};after') &&
        filters.targetDate.contains(
            '${DateTime.now().add(const Duration(days: 14)).toString().split(' ')[0]};before');

    oneMonth = filters.targetDate
            .contains('${DateTime.now().toString().split(' ')[0]};after') &&
        filters.targetDate.contains(
            '${DateTime.now().add(const Duration(days: 30)).toString().split(' ')[0]};before');

    twoMonths = filters.targetDate
            .contains('${DateTime.now().toString().split(' ')[0]};after') &&
        filters.targetDate.contains(
            '${DateTime.now().add(const Duration(days: 60)).toString().split(' ')[0]};before');

    customDate = (lastWeek || twoWeeks || oneMonth || twoMonths)
        ? false
        : filters.targetDate.isEmpty
            ? false
            : true;

    if (customDate) {
      _rangeDatePickerValueWithDefaultValue = [
        DateTime.parse(filters.targetDate[0].split(';')[0]),
        DateTime.parse(filters.targetDate[1].split(';')[0])
      ];
    }
  }

  @override
  void initState() {
    if (!widget.fromCreateView) {
      if (widget.issueCategory == IssueCategory.myIssues) {
        filters = ref.read(ProviderList.myIssuesProvider).issues.filters;
      } else {
        filters = ref.read(ProviderList.issuesProvider).issues.filters;
      }

      datesEnabled();
    } else {
      filters = Filters.fromJson(widget.filtersData["Filters"]);
      datesEnabled();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = ref.watch(ProviderList.themeProvider);
    var issuesProvider = ref.watch(ProviderList.issuesProvider);
    var projectProvider = ref.watch(ProviderList.projectProvider);
    var myIssuesProvider = ref.watch(ProviderList.myIssuesProvider);

    Widget expandedWidget(
        {required Widget icon,
        required String text,
        Color? color,
        required bool selected}) {
      return Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            blurRadius: 0.6,
            color: themeProvider.themeManager.borderSubtle01Color,
            spreadRadius: 0,
          )
        ], borderRadius: BorderRadius.circular(5), color: color),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(width: 5),
            CustomText(
              text.isNotEmpty
                  ? text.replaceFirst(text[0], text[0].toUpperCase())
                  : text,
              color: selected
                  ? Colors.white
                  : themeProvider.themeManager.secondaryTextColor,
            )
          ],
        ),
      );
    }

    Widget horizontalLine() {
      return Container(
        height: 1,
        width: double.infinity,
        color: themeProvider.themeManager.borderDisabledColor,
      );
    }

    return Container(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: Stack(
        children: [
          SizedBox(
            child: Row(
              children: [
                const CustomText(
                  '过滤',
                  type: FontStyle.H4,
                  fontWeight: FontWeightt.Semibold,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.close,
                    size: 27,
                    color: themeProvider.themeManager.placeholderTextColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 40, bottom: 80),
            child: SingleChildScrollView(
              child: Wrap(
                children: [
                  CustomExpansionTile(
                    title: '优先级',
                    child: Wrap(
                        children: priorities
                            .map((e) => GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (filters.priorities
                                        .contains(e['text'])) {
                                      filters.priorities.remove(e['text']);
                                    } else {
                                      filters.priorities.add(e['text']);
                                    }
                                  });
                                },
                                child: expandedWidget(
                                    icon: Icon(
                                      e['icon'],
                                      size: 15,
                                      color:
                                          filters.priorities.contains(e['text'])
                                              ? Colors.white
                                              : themeProvider.themeManager
                                                  .secondaryTextColor,
                                    ),
                                    text: e['title'] == 'null'
                                        ? '无'
                                        : e['title'],
                                    color: filters.priorities
                                            .contains(e['text'])
                                        ? themeProvider
                                            .themeManager.primaryColour
                                        : themeProvider.themeManager
                                            .secondaryBackgroundDefaultColor,
                                    selected: filters.priorities
                                        .contains(e['text']))))
                            .toList()),
                  ),

                  horizontalLine(),

                  CustomExpansionTile(
                    title: '状态',
                    child: Wrap(
                        children: (widget.issueCategory ==
                                    IssueCategory.myIssues
                                ? states
                                : issuesProvider.states.values)
                            .map((e) => GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (filters.states.contains(e['id'])) {
                                        filters.states.remove(e['id']);
                                      } else {
                                        filters.states.add(e['id']);
                                      }
                                    });
                                  },
                                  child: expandedWidget(
                                    icon: SvgPicture.asset(
                                      e['name'] == 'Backlog'
                                          ? 'assets/svg_images/circle.svg'
                                          : e['name'] == 'Cancelled'
                                              ? 'assets/svg_images/cancelled.svg'
                                              : e['name'] == 'Todo' ||
                                                      e['name'] == 'Started'
                                                  ? 'assets/svg_images/in_progress.svg'
                                                  : e['name'] == 'Done' ||
                                                          e['name'] ==
                                                              'Completed'
                                                      ? 'assets/svg_images/done.svg'
                                                      : 'assets/svg_images/circle.svg',
                                      colorFilter: ColorFilter.mode(
                                          filters.states.contains(e['id'])
                                              ? (Colors.white)
                                              : themeProvider.themeManager
                                                  .secondaryTextColor,
                                          BlendMode.srcIn),
                                      height: 20,
                                      width: 20,
                                    ),
                                    text: e['name'],
                                    color: filters.states.contains(e['id'])
                                        ? themeProvider
                                            .themeManager.primaryColour
                                        : themeProvider.themeManager
                                            .secondaryBackgroundDefaultColor,
                                    selected: filters.states.contains(e['id']),
                                  ),
                                ))
                            .toList()
                        // children: [
                        //   expandedWidget(
                        //       icon: Icons.dangerous_outlined, text: 'Backlog', selected: false),
                        //   expandedWidget(
                        //       icon: Icons.wifi_calling_3_outlined, text: 'To Do', selected: false),
                        //   expandedWidget(
                        //       icon: Icons.wifi_2_bar_outlined, text: 'In Progress', selected: false),
                        //   expandedWidget(
                        //       icon: Icons.wifi_1_bar_outlined, text: 'Done', selected: false),
                        //   expandedWidget(
                        //       icon: Icons.dangerous_outlined, text: 'Cancelled', selected: false),
                        // ],
                        ),
                  ),

                  widget.issueCategory == IssueCategory.myIssues
                      ? Container()
                      : horizontalLine(),

                  widget.issueCategory == IssueCategory.myIssues
                      ? Container()
                      : CustomExpansionTile(
                          title: '负责人',
                          child: Wrap(
                            children: projectProvider.projectMembers
                                .map(
                                  (e) => GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (filters.assignees
                                            .contains(e['member']['id'])) {
                                          filters.assignees
                                              .remove(e['member']['id']);
                                        } else {
                                          filters.assignees
                                              .add(e['member']['id']);
                                        }
                                      });
                                    },
                                    child: expandedWidget(
                                      icon: e['member']['avatar'] != '' &&
                                              e['member']['avatar'] != null
                                          ? CircleAvatar(
                                              radius: 10,
                                              backgroundImage: NetworkImage(
                                                  e['member']['avatar']),
                                            )
                                          : CircleAvatar(
                                              radius: 10,
                                              backgroundColor:
                                                  const Color.fromRGBO(
                                                      55, 65, 81, 1),
                                              child: Center(
                                                  child: CustomText(
                                                e['member']['display_name'][0]
                                                    .toString()
                                                    .toUpperCase(),
                                                color: Colors.white,
                                                fontWeight: FontWeightt.Medium,
                                                type: FontStyle.overline,
                                              )),
                                            ),
                                      text: e['member']['first_name'] != null &&
                                              e['member']['first_name'] != ''
                                          ? e['member']['first_name']
                                          : '',
                                      selected: filters.assignees
                                          .contains(e['member']['id']),
                                      color: filters.assignees
                                              .contains(e['member']['id'])
                                          ? themeProvider
                                              .themeManager.primaryColour
                                          : themeProvider.themeManager
                                              .secondaryBackgroundDefaultColor,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),

                  widget.issueCategory == IssueCategory.myIssues
                      ? Container()
                      : horizontalLine(),

                  widget.issueCategory == IssueCategory.myIssues
                      ? Container()
                      : CustomExpansionTile(
                          title: '创建人',
                          child: Wrap(
                            children: projectProvider.projectMembers
                                .map(
                                  (e) => GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (filters.createdBy
                                            .contains(e['member']['id'])) {
                                          filters.createdBy
                                              .remove(e['member']['id']);
                                        } else {
                                          filters.createdBy
                                              .add(e['member']['id']);
                                        }
                                      });
                                    },
                                    child: expandedWidget(
                                      icon: e['member']['avatar'] != '' &&
                                              e['member']['avatar'] != null
                                          ? CircleAvatar(
                                              radius: 10,
                                              backgroundImage: NetworkImage(
                                                  e['member']['avatar']),
                                            )
                                          : CircleAvatar(
                                              radius: 10,
                                              backgroundColor:
                                                  const Color.fromRGBO(
                                                      55, 65, 81, 1),
                                              child: Center(
                                                  child: CustomText(
                                                e['member']['display_name'][0]
                                                    .toString()
                                                    .toUpperCase(),
                                                color: Colors.white,
                                                fontWeight: FontWeightt.Medium,
                                                type: FontStyle.overline,
                                              )),
                                            ),
                                      text: e['member']['first_name'] != null &&
                                              e['member']['first_name'] != ''
                                          ? e['member']['first_name']
                                          : '',
                                      selected: filters.createdBy
                                          .contains(e['member']['id']),
                                      color: filters.createdBy
                                              .contains(e['member']['id'])
                                          ? themeProvider
                                              .themeManager.primaryColour
                                          : themeProvider.themeManager
                                              .secondaryBackgroundDefaultColor,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),

                  horizontalLine(),

                  CustomExpansionTile(
                    title: '标签',
                    child: Wrap(
                        children: (widget.issueCategory ==
                                    IssueCategory.myIssues
                                ? myIssuesProvider.labels
                                : issuesProvider.labels)
                            .map((e) => GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (filters.labels.contains(e['id'])) {
                                        filters.labels.remove(e['id']);
                                      } else {
                                        filters.labels.add(e['id']);
                                      }
                                    });
                                  },
                                  child: expandedWidget(
                                    icon: CircleAvatar(
                                        radius: 5,
                                        backgroundColor: (e['color'] == null ||
                                                e['color'][0] != '#')
                                            ? Colors.amber
                                            : Color(int.parse(
                                                "FF${e['color'].toString().replaceAll('#', '')}",
                                                radix: 16))),
                                    text: e['name'],
                                    selected: filters.labels.contains(e['id']),
                                    color: filters.labels.contains(e['id'])
                                        ? themeProvider
                                            .themeManager.primaryColour
                                        : themeProvider.themeManager
                                            .secondaryBackgroundDefaultColor,
                                  ),
                                ))
                            .toList()),
                  ),

                  horizontalLine(),

                  //due date\
                  CustomExpansionTile(
                    title: '到期时间',
                    child: Wrap(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (lastWeek) {
                                filters.targetDate = [];
                              } else {
                                filters.targetDate = [
                                  '${DateTime.now().subtract(const Duration(days: 7)).toString().split(' ')[0]};after',
                                  '${DateTime.now().toString().split(' ')[0]};before'
                                ];
                              }
                              datesEnabled();
                            });
                          },
                          child: expandedWidget(
                            icon: Icon(
                              Icons.calendar_today_outlined,
                              size: 15,
                              color: lastWeek
                                  ? Colors.white
                                  : themeProvider
                                      .themeManager.placeholderTextColor,
                            ),
                            text: '上周',
                            selected: lastWeek,
                            color: lastWeek
                                ? themeProvider.themeManager.primaryColour
                                : themeProvider.themeManager
                                    .secondaryBackgroundDefaultColor,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (twoWeeks) {
                                filters.targetDate = [];
                              } else {
                                filters.targetDate = [
                                  '${DateTime.now().toString().split(' ')[0]};after',
                                  '${DateTime.now().add(const Duration(days: 14)).toString().split(' ')[0]};before'
                                ];
                              }
                              datesEnabled();
                            });
                          },
                          child: expandedWidget(
                            icon: Icon(
                              Icons.calendar_today_outlined,
                              size: 15,
                              color: twoWeeks
                                  ? Colors.white
                                  : themeProvider
                                      .themeManager.placeholderTextColor,
                            ),
                            text: '2 周后',
                            selected: twoWeeks,
                            color: twoWeeks
                                ? themeProvider.themeManager.primaryColour
                                : themeProvider.themeManager
                                    .secondaryBackgroundDefaultColor,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (oneMonth) {
                                filters.targetDate = [];
                              } else {
                                filters.targetDate = [
                                  '${DateTime.now().toString().split(' ')[0]};after',
                                  '${DateTime.now().add(const Duration(days: 30)).toString().split(' ')[0]};before'
                                ];
                              }

                              datesEnabled();
                            });
                          },
                          child: expandedWidget(
                            icon: Icon(
                              Icons.calendar_today_outlined,
                              size: 15,
                              color: oneMonth
                                  ? Colors.white
                                  : themeProvider
                                      .themeManager.placeholderTextColor,
                            ),
                            text: '1个月后',
                            selected: oneMonth,
                            color: oneMonth
                                ? themeProvider.themeManager.primaryColour
                                : themeProvider.themeManager
                                    .secondaryBackgroundDefaultColor,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (twoMonths) {
                                filters.targetDate = [];
                              } else {
                                filters.targetDate = [
                                  '${DateTime.now().toString().split(' ')[0]};after',
                                  '${DateTime.now().add(const Duration(days: 60)).toString().split(' ')[0]};before'
                                ];
                              }
                              datesEnabled();
                            });
                          },
                          child: expandedWidget(
                            icon: Icon(
                              Icons.calendar_today_outlined,
                              size: 15,
                              color: twoMonths
                                  ? Colors.white
                                  : themeProvider
                                      .themeManager.placeholderTextColor,
                            ),
                            text: '2个月后',
                            selected: twoMonths,
                            color: twoMonths
                                ? themeProvider.themeManager.primaryColour
                                : themeProvider.themeManager
                                    .secondaryBackgroundDefaultColor,
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            showModalBottomSheet(
                                isScrollControlled: true,
                                enableDrag: true,
                                constraints: BoxConstraints(
                                    maxHeight:
                                        MediaQuery.of(context).size.height *
                                            0.85),
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  topRight: Radius.circular(30),
                                )),
                                context: context,
                                builder: (ctx) {
                                  return Wrap(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.only(
                                            top: 15, left: 15, right: 15),
                                        child: Row(
                                          children: [
                                            const CustomText(
                                              '自定义日期',
                                              type: FontStyle.H4,
                                              fontWeight: FontWeightt.Semibold,
                                            ),
                                            const Spacer(),
                                            IconButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              icon: Icon(
                                                Icons.close,
                                                size: 27,
                                                color: themeProvider
                                                    .themeManager
                                                    .placeholderTextColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      CalendarDatePicker2(
                                        config: CalendarDatePicker2Config(
                                          calendarType:
                                              CalendarDatePicker2Type.range,
                                          selectedDayHighlightColor:
                                              themeProvider
                                                  .themeManager.primaryColour,
                                          weekdayLabelTextStyle: TextStyle(
                                            color: themeProvider
                                                .themeManager.primaryTextColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          controlsTextStyle: TextStyle(
                                            color: themeProvider
                                                .themeManager.primaryTextColor,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          dayTextStyle: TextStyle(
                                            color: themeProvider.themeManager
                                                .secondaryTextColor,
                                          ),
                                        ),
                                        value:
                                            _rangeDatePickerValueWithDefaultValue,
                                        onValueChanged: (dates) => setState(() =>
                                            _rangeDatePickerValueWithDefaultValue =
                                                dates),
                                      ),

                                      // two buttons taking up the whole width of the bottom sheet one to cancel and one to apply

                                      Container(
                                        padding: const EdgeInsets.only(
                                            left: 20, right: 20, bottom: 20),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Expanded(
                                              child: Button(
                                                text: '清除',
                                                filledButton: false,
                                                color: themeProvider
                                                    .themeManager
                                                    .primaryBackgroundDefaultColor,
                                                ontap: () {
                                                  filters.targetDate = [];
                                                  Navigator.pop(context);
                                                },
                                                textColor: themeProvider
                                                    .themeManager
                                                    .secondaryTextColor,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Button(
                                                text: '应用',
                                                ontap: () {
                                                  if (_rangeDatePickerValueWithDefaultValue
                                                          .length !=
                                                      2) {
                                                    CustomToast().showToast(
                                                        context,
                                                        '请选择日期范围',
                                                        themeProvider,
                                                        toastType:
                                                            ToastType.warning);
                                                    return;
                                                  }
                                                  setState(() {
                                                    filters.targetDate = [
                                                      '${_rangeDatePickerValueWithDefaultValue[0].toString().split(' ')[0]};after',
                                                      '${_rangeDatePickerValueWithDefaultValue[1].toString().split(' ')[0]};before'
                                                    ];
                                                    datesEnabled();
                                                  });
                                                  Navigator.pop(context);
                                                },
                                                textColor: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  );
                                });
                          },
                          child: expandedWidget(
                            icon: Icon(
                              Icons.calendar_today_outlined,
                              size: 15,
                              color: customDate
                                  ? Colors.white
                                  : themeProvider
                                      .themeManager.secondaryTextColor,
                            ),
                            text: '自定义日期',
                            selected: customDate,
                            color: customDate
                                ? themeProvider.themeManager.primaryColour
                                : themeProvider.themeManager
                                    .secondaryBackgroundDefaultColor,
                          ),
                        ),
                      ],
                      // children: [
                      //   expandedWidget(
                      //       icon: Icons.calendar_today_outlined, text: 'Today', selected: false),
                      //   expandedWidget(
                      //       icon: Icons.calendar_today_outlined, text: 'Tomorrow', selected: false),
                      //   expandedWidget(
                      //       icon: Icons.calendar_today_outlined, text: 'This Week', selected: false),
                      //   expandedWidget(
                      //       icon: Icons.calendar_today_outlined, text: 'This Month', selected: false),
                      //   expandedWidget(
                      //       icon: Icons.calendar_today_outlined, text: 'This Quarter', selected: false),
                      //   expandedWidget(
                      //       icon: Icons.calendar_today_outlined, text: 'This Year', selected: false),
                      // ],
                    ),
                  ),

                  // Expanded(child: Container()),

                  //long blue button to apply filter
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              height: 50,
              width: MediaQuery.sizeOf(context).width - 40,
              margin: const EdgeInsets.only(bottom: 18),
              child: Button(
                text: widget.fromCreateView ? '添加过滤' : '应用过滤',
                ontap: () {
                  if (widget.fromCreateView) {
                    widget.filtersData["Filters"] = Filters.toJson(filters);

                    Navigator.pop(context);
                    return;
                  }
                  widget.issueCategory == IssueCategory.myIssues
                      ? myIssuesProvider.issues.filters = filters
                      : issuesProvider.issues.filters = filters;
                  if (widget.issueCategory == IssueCategory.cycleIssues) {
                    ref
                        .watch(ProviderList.cyclesProvider)
                        .filterCycleIssues(
                          slug: ref
                              .read(ProviderList.workspaceProvider)
                              .selectedWorkspace!
                              .workspaceSlug,
                          projectId: ref
                              .read(ProviderList.projectProvider)
                              .currentProject["id"],
                        )
                        .then((value) => ref
                            .watch(ProviderList.cyclesProvider)
                            .initializeBoard());
                  } else if (widget.issueCategory ==
                      IssueCategory.moduleIssues) {
                    ref
                        .watch(ProviderList.modulesProvider)
                        .filterModuleIssues(
                          slug: ref
                              .read(ProviderList.workspaceProvider)
                              .selectedWorkspace!
                              .workspaceSlug,
                          projectId: ref
                              .read(ProviderList.projectProvider)
                              .currentProject["id"],
                        )
                        .then((value) => ref
                            .watch(ProviderList.modulesProvider)
                            .initializeBoard());
                  } else if (widget.issueCategory == IssueCategory.myIssues) {
                    ref
                        .watch(ProviderList.myIssuesProvider)
                        .updateMyIssueView();
                    ref.watch(ProviderList.myIssuesProvider).filterIssues();
                  } else {
                    issuesProvider.updateProjectView();
                    issuesProvider.filterIssues(
                      slug: ref
                          .read(ProviderList.workspaceProvider)
                          .selectedWorkspace!
                          .workspaceSlug,
                      projID: ref
                          .read(ProviderList.projectProvider)
                          .currentProject["id"],
                    );
                  }
                  Navigator.of(context).pop();
                },
                textColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
