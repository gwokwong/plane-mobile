// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plane_startup/bottom_sheets/company_size_sheet.dart';
import 'package:plane_startup/bottom_sheets/delete_workspace_sheet.dart';
import 'package:plane_startup/provider/provider_list.dart';
import 'package:plane_startup/utils/constants.dart';
import 'package:plane_startup/bottom_sheets/workspace_logo.dart';
import 'package:plane_startup/utils/custom_toast.dart';
import 'package:plane_startup/utils/enums.dart';
import 'package:plane_startup/widgets/custom_app_bar.dart';
import 'package:plane_startup/widgets/custom_text.dart';
import 'package:plane_startup/widgets/loading_widget.dart';

class WorkspaceGeneral extends ConsumerStatefulWidget {
  const WorkspaceGeneral({super.key});

  @override
  ConsumerState<WorkspaceGeneral> createState() => _WorkspaceGeneralState();
}

class _WorkspaceGeneralState extends ConsumerState<WorkspaceGeneral> {
  final TextEditingController _workspaceNameController =
      TextEditingController();
  final TextEditingController _workspaceUrlController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _workspaceNameController.text = ref
        .read(ProviderList.workspaceProvider)
        .selectedWorkspace!
        .workspaceName;

    ref.read(ProviderList.workspaceProvider).changeCompanySize(
        size: ref
            .read(ProviderList.workspaceProvider)
            .selectedWorkspace!
            .workspaceSize
            .toString());

    dropDownValue = ref
        .read(ProviderList.workspaceProvider)
        .selectedWorkspace!
        .workspaceSize
        .toString();

    _workspaceUrlController.text = ref
        .read(ProviderList.workspaceProvider)
        .selectedWorkspace!
        .workspaceUrl;
  }

  String? dropDownValue;
  List<String> dropDownItems = ['5', '10', '25', '50'];
  @override
  Widget build(BuildContext context) {
    var themeProvider = ref.watch(ProviderList.themeProvider);
    var workspaceProvider = ref.watch(ProviderList.workspaceProvider);
    // imageUrl = ref
    //     .read(ProviderList.workspaceProvider)
    //     .selectedWorkspace!
    //     .workspaceLogo;
    return WillPopScope(
      onWillPop: () async {
        workspaceProvider.changeLogo(
            logo: workspaceProvider.selectedWorkspace!.workspaceLogo);
        return true;
      },
      child: Scaffold(
        appBar: CustomAppBar(
          onPressed: () {
            workspaceProvider.changeLogo(
                logo: workspaceProvider.selectedWorkspace!.workspaceLogo);
            Navigator.of(context).pop();
          },
          text: '工作区概况',
        ),
        body: LoadingWidget(
          loading: workspaceProvider.updateWorkspaceState == StateEnum.loading,
          widgetClass: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  height: 1,
                  width: MediaQuery.of(context).size.width,
                  color: themeProvider.themeManager.borderSubtle01Color,
                ),
                Container(
                  margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        child: Container(
                          height: 45,
                          width: 45,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: workspaceProvider.tempLogo == ''
                                ? themeProvider.themeManager.primaryColour
                                : null,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          //image
                          child: workspaceProvider.tempLogo == ''
                              ? SizedBox(
                                  child: CustomText(
                                    workspaceProvider
                                        .selectedWorkspace!.workspaceName
                                        .toString()
                                        .toUpperCase()[0],
                                    type: FontStyle.Medium,
                                    fontWeight: FontWeightt.Semibold,
                                    // fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                    overrride: true,
                                  ),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(
                                    workspaceProvider.tempLogo,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          if (workspaceProvider.role != Role.admin &&
                              workspaceProvider.role != Role.member) {
                            CustomToast().showToast(
                                context,
                                '不允许修改logo',
                                themeProvider,
                                toastType: ToastType.warning);
                            return;
                          }
                          showModalBottomSheet(
                              isScrollControlled: true,
                              enableDrag: true,
                              constraints: const BoxConstraints(maxHeight: 370),
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30),
                              )),
                              context: context,
                              builder: (ctx) {
                                return const WorkspaceLogo();
                              });
                          // var file = await ImagePicker.platform
                          //     .pickImage(source: ImageSource.gallery);
                          // if (file != null) {
                          //   setState(() {
                          //     coverImage = File(file.path);
                          //   });
                          // }
                        },
                        child: Container(
                            margin: const EdgeInsets.only(left: 16),
                            height: 45,
                            width: 100,
                            decoration: BoxDecoration(
                              color: themeProvider
                                  .themeManager.secondaryBackgroundDefaultColor,
                              border: Border.all(
                                  color: themeProvider
                                      .themeManager.borderSubtle01Color),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.file_upload_outlined,
                                  color: themeProvider
                                      .themeManager.placeholderTextColor,
                                ),
                                const SizedBox(width: 5),
                                const CustomText(
                                  '上传',
                                  type: FontStyle.Small,
                                ),
                              ],
                            )),
                      ),
                      workspaceProvider.tempLogo != ''
                          ? GestureDetector(
                              onTap: () {
                                if (workspaceProvider.role != Role.admin &&
                                    workspaceProvider.role != Role.member) {
                                  CustomToast().showToast(
                                      context,
                                      '不允许更改logo',
                                      themeProvider,
                                      toastType: ToastType.warning);
                                  return;
                                }
                                workspaceProvider.removeLogo();
                                // workspaceProvider.removeLogo();
                              },
                              child: Container(
                                  margin: const EdgeInsets.only(left: 16),
                                  height: 45,
                                  width: 100,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: themeProvider
                                            .themeManager.borderSubtle01Color),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: CustomText(
                                    'Remove',
                                    color: Colors.red.shade600,
                                    type: FontStyle.Small,
                                  )),
                            )
                          : Container(),
                    ],
                  ),
                ),
                Container(
                    margin: const EdgeInsets.only(
                        left: 20, right: 20, top: 20, bottom: 5),
                    child: const Row(
                      children: [
                        CustomText(
                          '工作区名称 ',
                          type: FontStyle.Small,
                        ),
                        CustomText(
                          '*',
                          type: FontStyle.Small,
                          color: Colors.red,
                        ),
                      ],
                    )),
                Container(
                  //  height: 50,
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                  ),
                  child: TextFormField(
                      readOnly: workspaceProvider.role != Role.admin &&
                          workspaceProvider.role != Role.member,
                      controller: _workspaceNameController,
                      decoration:
                          themeProvider.themeManager.textFieldDecoration),
                ),
                Container(
                    margin: const EdgeInsets.only(
                        left: 20, right: 20, top: 20, bottom: 5),
                    child: const Row(
                      children: [
                        CustomText(
                          '工作区网址 ',
                          type: FontStyle.Small,
                        ),
                        CustomText(
                          '*',
                          type: FontStyle.Small,
                          color: Colors.red,
                        ),
                      ],
                    )),
                Container(
                  //  height: 50,
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                  ),
                  child: TextFormField(
                      controller: _workspaceUrlController,
                      //not editable
                      //enabled: true,
                      onTap: () {
                        CustomToast().showToast(
                            context, accessRestrictedMSG, themeProvider,
                            toastType: ToastType.failure);
                      },
                      readOnly: true,
                      //style: ,
                      decoration:
                          themeProvider.themeManager.textFieldDecoration),
                ),
                Container(
                    margin: const EdgeInsets.only(
                        left: 20, right: 20, top: 20, bottom: 5),
                    child: const Row(
                      children: [
                        CustomText(
                          '公司规模 ',
                          type: FontStyle.Small,
                        ),
                        CustomText(
                          '*',
                          type: FontStyle.Small,
                          color: Colors.red,
                        ),
                      ],
                    )),
                // Container(
                //   height: 50,
                //   color: Colors.transparent,
                //   padding: const EdgeInsets.only(
                //     left: 20,
                //     right: 20,
                //   ),
                // decoration: BoxDecoration(
                //   borderRadius: BorderRadius.circular(8),
                //   border: Border.all(
                //     color: Colors.grey.shade500,
                //   ),
                // ),
                // padding: const EdgeInsets.symmetric(
                //     horizontal: 10, vertical: 4),
                // child: DropdownButtonFormField(
                //   dropdownColor: themeProvider.isDarkThemeEnabled
                //       ? darkSecondaryBGC
                //       : Colors.white,
                //   value: dropDownValue,
                //   elevation: 1,
                //   //padding to dropdown
                //   isExpanded: false,
                //   decoration: themeProvider.themeManager.textFieldDecoration.copyWith(
                //     ),

                //   // underline: Container(color: Colors.transparent),
                //   icon: const Icon(Icons.keyboard_arrow_down),
                //   items: dropDownItems.map((String items) {
                //     return DropdownMenuItem(
                //       value: items,
                //       child: SizedBox(
                //         // width: MediaQuery.of(context).size.width - 80,
                //         // child: Text(items),
                //         child: CustomText(
                //           items,
                //           type: FontStyle.Small,
                //         ),
                //       ),
                //     );
                //   }).toList(),
                //   onChanged: (String? newValue) {
                //     setState(() {
                //       dropDownValue = newValue!;
                //     });
                //   },
                // ),

                //convert above dropdown to bottomsheet
                // child:
                GestureDetector(
                  onTap: () {
                    if (workspaceProvider.role != Role.admin &&
                        workspaceProvider.role != Role.member) {
                      CustomToast().showToast(
                          context, accessRestrictedMSG, themeProvider,
                          toastType: ToastType.failure);
                      return;
                    }
                    showModalBottomSheet(
                        context: context,
                        constraints: BoxConstraints(
                          minHeight: height * 0.5,
                          maxHeight: MediaQuery.of(context).size.height * 0.5,
                        ),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        builder: (context) {
                          return const CompanySize();
                        });
                  },
                  child: Container(
                    margin:
                        const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(
                          color:
                              themeProvider.themeManager.borderSubtle01Color),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 16),
                          child: CustomText(
                            workspaceProvider.companySize == ''
                                ? '选择公司规模'
                                : workspaceProvider.companySize,
                            type: FontStyle.Small,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(right: 16),
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: themeProvider.themeManager.primaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ),
                ),
                GestureDetector(
                  onTap: () async {
                    await workspaceProvider.updateWorkspace(data: {
                      'name': _workspaceNameController.text,
                      //convert to int
                      'organization_size': workspaceProvider.companySize,
                      'logo': workspaceProvider.tempLogo,
                    });
                    if (workspaceProvider.updateWorkspaceState ==
                        StateEnum.success) {
                      CustomToast().showToast(context,
                          '工作区更新成功', themeProvider,
                          toastType: ToastType.success);
                    }
                    if (workspaceProvider.updateWorkspaceState ==
                        StateEnum.error) {
                      CustomToast().showToast(
                          context,
                          'Something went wrong, please try again',
                          themeProvider,
                          toastType: ToastType.failure);
                    }
                    // refreshImage();
                  },
                  child: Container(
                      height: 45,
                      width: MediaQuery.of(context).size.width,
                      margin:
                          const EdgeInsets.only(top: 20, left: 20, right: 20),
                      decoration: BoxDecoration(
                        color: themeProvider.themeManager.primaryColour,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Center(
                          child: CustomText(
                        '更新',
                        color: Colors.white,
                        type: FontStyle.Medium,
                        fontWeight: FontWeightt.Bold,
                        overrride: true,
                      ))),
                ),
                Container(
                  decoration: BoxDecoration(
                      //light red
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: const Color.fromRGBO(255, 12, 12, 1))),
                  margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
                  child: ExpansionTile(
                    childrenPadding:
                        const EdgeInsets.only(left: 15, right: 15, bottom: 10),
                    iconColor: themeProvider.themeManager.primaryTextColor,
                    collapsedIconColor:
                        themeProvider.themeManager.primaryTextColor,
                    backgroundColor: const Color.fromRGBO(255, 12, 12, 0.1),
                    collapsedBackgroundColor:
                        const Color.fromRGBO(255, 12, 12, 0.1),
                    title: const CustomText(
                      '危险区域',
                      textAlign: TextAlign.left,
                      type: FontStyle.H5,
                      color: Color.fromRGBO(255, 12, 12, 1),
                    ),
                    children: [
                      const CustomText(
                        '工作区删除页面的危险区域是需要仔细考虑和注意的关键区域。删除工作区时，该工作区中的所有数据和资源将被永久删除，且无法恢复。',
                        type: FontStyle.Medium,
                        maxLines: 8,
                        textAlign: TextAlign.left,
                        color: Colors.grey,
                      ),
                      GestureDetector(
                        onTap: () async {
                          showModalBottomSheet(
                            isScrollControlled: true,
                            enableDrag: true,
                            constraints: BoxConstraints(
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.8),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30),
                              ),
                            ),
                            context: context,
                            builder: (BuildContext context) => Padding(
                              padding: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.viewInsetsOf(context).bottom),
                              child: DeleteWorkspace(
                                workspaceName: workspaceProvider
                                    .selectedWorkspace!.workspaceName,
                              ),
                            ),
                          );
                        },
                        child: Container(
                            height: 45,
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.only(top: 20, bottom: 15),
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(255, 12, 12, 1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Center(
                                child: CustomText(
                              '删除工作区',
                              color: Colors.white,
                              type: FontStyle.Medium,
                              fontWeight: FontWeightt.Bold,
                            ))),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
