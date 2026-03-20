import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Extension/text_field_extenstion.dart';
import 'package:AccuChat/Screens/Chat/models/chat_history_response_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../Constants/assets.dart';
import '../../../../../../Constants/themes.dart';
import '../../../../../../Services/APIs/api_ends.dart';
import '../../../../../../utils/common_textfield.dart';
import '../../../../../../utils/custom_dialogue.dart';
import '../../../../../../utils/custom_flashbar.dart';
import '../../../../../../utils/helper_widget.dart';
import '../../../../../../utils/hover_glass_effect_widget.dart';
import '../../../../../../utils/networl_shimmer_image.dart';
import '../../../../../../utils/text_style.dart';
import '../../../../api/apis.dart';
import '../../../../models/all_media_res_model.dart';
import '../Controllers/gallery_view_controller.dart';
import '../Controllers/members_gr_br_controller.dart';
import '../Controllers/view_profile_controller.dart';
import 'images_gallery_page.dart';

class ProfileMediaSectionGetX extends StatelessWidget {
  final String baseUrl;
  const ProfileMediaSectionGetX({super.key, required this.baseUrl});

  @override
  Widget build(BuildContext context) {
    ViewProfileController controller;
    if(Get.isRegistered<ViewProfileController>()) {
      controller = Get.find<ViewProfileController>();
    }else{
      controller = Get.put(ViewProfileController());
    }

    return
      DefaultTabController(
        length: 2,
        child: Builder(
          builder: (context) {
              final tabCtrl = DefaultTabController.of(context);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                controller.attachTabController(tabCtrl);
              });

            return Column(
              children: [
            HoverGlassEffect(
            borderRadius: 12,
            hoverScale: 1.04,
            normalBlur: 3,
            hoverBlur: 10,
            gradient: LinearGradient(colors: [
              perpleBg,
              whiteselected
            ]),
                hoverGradient: LinearGradient(colors: [
              perplebr,
              whiteselected
            ]),
            child:TabBar(
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color:appColorGreen)
                    ),
                    indicatorPadding: EdgeInsets.zero,
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.black54,
                    padding: EdgeInsets.symmetric(
                        horizontal: 4,vertical: 4
                    ),
                    tabs: const [
                      Tab(text: 'Photos & Videos'),
                      Tab(text: 'Documents'),
                    ],
                  )
                ),

                const SizedBox(height: 12),

                SizedBox(
                  height: 400,
                  child: TabBarView(
                    children: [
                      Obx(() => _MediaGrid(
                        baseUrl: ApiEnd.baseUrlMedia,
                        onTapF: (){},
                        controller: controller,
                        items: controller.profileMediaList
                            .where((m) => isImageOrVideo(m))
                            .toList(),
                      )),

                      Obx(() =>_DocsList(
                        baseUrl: ApiEnd.baseUrlMedia,
                        controller: controller,
                        items: controller.profileMediaList
                            .where((m) => isDoc(m))
                            .toList(),
                      )),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      )
    ;
  }
}


class ProfileMediaSectionGetXGroup extends StatelessWidget {
  final String baseUrl;
  const ProfileMediaSectionGetXGroup({super.key, required this.baseUrl});

  @override
  Widget build(BuildContext context) {
    GrBrMembersController controller;
    if(Get.isRegistered<GrBrMembersController>()) {
      controller = Get.find<GrBrMembersController>();
    }else{
      controller = Get.put(GrBrMembersController());
    }

    return
      DefaultTabController(
        length: 3,
        child: Builder(
          builder: (context) {
              final tabCtrl = DefaultTabController.of(context);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                controller.attachTabController(tabCtrl);
              });

            return Column(
              children: [
                Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  child:TabBar(
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color:appColorGreen)
                    ),

                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.black54,
                    padding: EdgeInsets.symmetric(
                      horizontal: 4
                    ),
                    tabs: const [
                      Tab(text: 'Members'),
                      Tab(text: 'Photos & Videos'),
                      Tab(text: 'Documents'),
                    ],
                  )
                ),

                const SizedBox(height: 12),

                SizedBox(
                  height: 500,
                  child: TabBarView(
                    children: [
                      GetBuilder<GrBrMembersController>(
                        builder: (controller) {
                          return Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                image: DecorationImage(image: AssetImage(appbarBG),fit: BoxFit.cover)
                            ),
                            child: Column(
                              children: [
                                CustomTextField(
                                  hintText: controller.groupOrBr?.userCompany?.isGroup == 1
                                      ? "Group Name"
                                      : "Broadcast Name",
                                  labletext: "",
                                  readOnly:
                                  (controller.groupOrBr?.createdBy == APIs.me?.userCompany?.userCompanyId)
                                      ? false
                                      : true,
                                  controller: controller.groupNameController,
                                  onChangee: (v) {
                                    controller.isUpdate = true;
                                    controller.update();
                                  },
                                  validator: (value) {
                                    return value?.isEmptyField(
                                        messageTitle:
                                        controller.groupOrBr?.userCompany?.isGroup == 1
                                            ? "Group Name"
                                            : "Broadcast Name");
                                  },
                                  prefix: Icon(
                                    Icons.group,
                                    color: appColorPerple,
                                  ),
                                ).marginSymmetric(horizontal: 20, vertical: 5),

                                if (controller.isUpdate)
                                  dynamicButton(
                                      name: "Update",
                                      onTap: controller.groupNameController.text.isNotEmpty
                                          ? () => controller.updateGroupBroadcastApi(
                                        isGroup: controller.groupOrBr?.userCompany
                                            ?.isGroup ==
                                            1
                                            ? 1
                                            : 0,
                                        isBroadcast: controller.groupOrBr?.userCompany
                                            ?.isBroadcast ==
                                            1
                                            ? 1
                                            : 0,
                                      )
                                          : () {
                                        toast("Name cannot be empty");
                                      },
                                      isShowText: true,
                                      isShowIconText: false,
                                      gradient: buttonGradient,
                                      leanIcon: arrowDownPng),

                                const SizedBox(height: 10),

                                Expanded(
                                  child: ListView.builder(
                                    itemCount: controller.members.length,
                                    itemBuilder: (context, index) {
                                      final member = controller.members[index];
                                      final isAdmin = member.isAdmin == 1 ? true : false;
                                      final me = APIs.me;

                                      final usern = (member.userCompany?.displayName != null)
                                          ? member.userCompany?.displayName ?? ''
                                          : member.userName ?? '';
                                      final bool isSelf =
                                          member.userId == me?.userId;
                                      final int? creatorUserId =
                                          controller.groupOrBr?.createdBy ??
                                              controller.groupOrBr?.createdBy;

                                      final bool iAmCreator =
                                          me?.userCompany?.userCompanyId == creatorUserId;
                                      final bool targetIsCreator =
                                          member.userCompany?.userCompanyId == creatorUserId;

                                      final bool iAmAdmin = (me?.isAdmin ?? 0) == 1;
                                      final bool targetIsAdmin = (member.isAdmin ?? 0) == 1;

                                      final bool iAmMemberOnly =
                                          !iAmCreator && !iAmAdmin;

                                      final bool isGroup =
                                          (controller.groupOrBr?.userCompany?.isGroup ?? 0) == 1;

                                      final bool showMenu = !isSelf &&
                                          !iAmMemberOnly &&
                                          !(iAmAdmin && targetIsCreator);

                                      final bool canMakeAdmin = !targetIsAdmin &&
                                          (iAmCreator || iAmAdmin);

                                      final bool canRemove = (iAmCreator && !isSelf) ||
                                          (iAmAdmin && !targetIsCreator && !isSelf);

                                      return
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 6, horizontal: 10),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(12),
                                            boxShadow: kIsWeb
                                                ? [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.06),
                                                blurRadius: 12,
                                                spreadRadius: 1,
                                                offset: const Offset(0, 4),
                                              )
                                            ]
                                                : [],
                                          ),

                                          child: ListTile(
                                            contentPadding: const EdgeInsets.symmetric(
                                                vertical: 0, horizontal: 12),
                                            leading: SizedBox(
                                              width: 50,
                                              child:
                                              member.userImage!=null? CustomCacheNetworkImage(
                                                "${ApiEnd.baseUrlMedia}${member.userImage ?? ''}",
                                                radiusAll: 100,
                                                height: 50,
                                                width: 50,
                                                defaultImage: ICON_profile,
                                                borderColor: greyColor,
                                                boxFit: BoxFit.cover,
                                              ):CircleAvatar(
                                                // radius: 45,
                                                backgroundColor: perpleBg,
                                                child: Text(getInitials(usern),style: BalooStyles.baloosemiBoldTextStyle(color: perplebr,),),
                                              ),
                                            ),

                                            title: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  member.userCompany?.displayName!=null?
                                                  member.userCompany?.displayName?? '':member.userName!=null?
                                                  member.userName??'':member.phone??'',
                                                  style: BalooStyles.baloonormalTextStyle(),
                                                ),
                                                if (isAdmin ?? true)
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 6),
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(
                                                          horizontal: 6, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: appColorGreen,
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                      child: const Text('admin',
                                                          style: TextStyle(
                                                              fontSize: 10,
                                                              color: Colors.white)),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            subtitle: Text(
                                              member.phone == '' ||
                                                  member.phone == null
                                                  ? member.email ?? ''
                                                  : member.phone ?? '',
                                              style: BalooStyles.baloonormalTextStyle(color: greyText),
                                            ),
                                            trailing: showMenu
                                                ? PopupMenuButton<String>(
                                              onSelected: (value) {
                                                if (value == 'make_admin') {
                                                  controller.hitAPIToUpdateMember(
                                                    mode: "set_admin",
                                                    isGroup: isGroup,
                                                    id: member.userCompany?.userCompanyId,
                                                  );
                                                } else if (value == 'remove') {
                                                  controller.hitAPIToUpdateMember(
                                                    mode: "remove",
                                                    isGroup: isGroup,
                                                    id: member.userCompany?.userCompanyId,
                                                  );
                                                }
                                              },
                                              itemBuilder: (context) => [
                                                if (canMakeAdmin)
                                                  PopupMenuItem(
                                                    value: 'make_admin',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.circle_rounded,
                                                            size: 12,
                                                            color: appColorGreen),
                                                        hGap(5),
                                                        Text('Make Admin',
                                                            style: BalooStyles.baloonormalTextStyle()),
                                                      ],
                                                    ),
                                                  ),
                                                if (canRemove)
                                                  PopupMenuItem(
                                                    value: 'remove',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.remove_circle,
                                                            size: 12,
                                                            color: AppTheme.redErrorColor),
                                                        hGap(5),
                                                        Text('Remove Member',
                                                            style: BalooStyles.baloonormalTextStyle()),
                                                      ],
                                                    ),
                                                  ),
                                              ],
                                              color: Colors.white,
                                              icon: const Icon(Icons.more_vert),
                                            )
                                                : null,
                                            onTap: () {},
                                          ),
                                        );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      ),

                      Obx(() => _MediaGrid(
                        baseUrl: ApiEnd.baseUrlMedia,
                        onTapF: (){},
                        controller: controller,
                        items: controller.profileMediaList
                            .where((m) => isImageOrVideo(m))
                            .toList(),
                      )),

                      Obx(() => _DocsList(
                        baseUrl: ApiEnd.baseUrlMedia,
                        controller: controller,
                        items: controller.profileMediaList
                            .where((m) => isDoc(m))
                            .toList(),
                      )),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      )
    ;
  }
}


class _MediaGrid extends StatelessWidget {
  final String baseUrl;
  final List<Items> items;
  final Function() onTapF;
  final  controller;
  const _MediaGrid({required this.baseUrl, required this.items,required this.controller, required this.onTapF});

  int _columnsForWidth(double w) {
    // tweak breakpoints as you like
    if (w < 480) return 3;        // phones
    if (w < 720) return 4;        // small tablets
    if (w < 1024) return 5;       // large tablets
    if (w < 1440) return 6;       // small desktops
    if (w < 1920) return 8;       // desktops
    return 10;                    // big screens/4K
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(child: Text('No media found', style: BalooStyles.baloonormalTextStyle()));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = _columnsForWidth(constraints.maxWidth);

        // remove glow + use platform-appropriate physics (bouncing on mobile, clamping on web)
        return Container(
         decoration: BoxDecoration(
           borderRadius: BorderRadius.circular(15),
           image: DecorationImage(image: AssetImage(appbarBG),fit: BoxFit.cover)
         ),
          child: GridView.builder(
            physics: kIsWeb ? const ClampingScrollPhysics() : const BouncingScrollPhysics(),
            controller: controller.scrollController,
            padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8, top: 8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.3 , // keep squares; adjust if you want cards
            ),
            itemCount: items.length,
            itemBuilder: (_, i) {
              final m = items[i];
              final url = '$baseUrl${m.fileName ?? ''}';
              return InkWell(
                onTap: (){
                  Get.to(
                        () => GalleryViewerPage(
                      isChat: true,
                      onReply: (){

                        Get.back();
                        // controller.refIdis = data.chatId;
                        // controller.userIDSender =
                        //     data.fromUser?.userId;
                        // controller.userNameReceiver =
                        //     data.toUser?.displayName ?? '';
                        // controller.userNameSender =
                        //     data.fromUser?.displayName ?? '';
                        // controller.userIDReceiver =
                        //     data.toUser?.userId;
                        // controller.replyToMessage =data;
                      },),
                    binding: BindingsBuilder(() {
                      Get.put(GalleryViewerController(
                          urls: items.map((v)=>"${ApiEnd.baseUrlMedia}${v.fileName}").toList()
                          , index: i,
                          chathis: ChatHisList()));
                    }),
                    fullscreenDialog: true,
                    transition: Transition.fadeIn,
                  );
                },
                child: HoverGlassEffect(
                  margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  borderRadius: 12,
                  hoverScale: 1.015,
                  normalBlur: 3,
                  hoverBlur: 10,
                  gradient:  LinearGradient(colors: [
                    gallwhite,
                    perpleBg.withOpacity(.2),
                  ]),
                  child: CustomCacheNetworkImage(
                    url,
                    height: double.infinity,
                    width: double.infinity,
                    borderWidth: 1,
                    boxFit: BoxFit.cover,
                    borderColor: greyColor,
                    radiusAll: 6,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}


/*class _MediaGrid extends StatelessWidget {
  final String baseUrl;
  final List<Items> items;
  final Function() onTapF;
  final ViewProfileController controller;
  const _MediaGrid({required this.baseUrl, required this.items,required this.controller, required this.onTapF});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(child: Text('No media found', style: BalooStyles.baloonormalTextStyle()));
    }
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      controller: controller.scrollController,
      padding: const EdgeInsets.only(bottom: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, crossAxisSpacing: 4, mainAxisSpacing: 4,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final m = items[i];
        final url = '$baseUrl${m.fileName ?? ''}';
        return InkWell(
          onTap: (){
            Get.to(
                  () => GalleryViewerPage(
                    isChat: true,
                    onReply: (){

                Get.back();
                // controller.refIdis = data.chatId;
                // controller.userIDSender =
                //     data.fromUser?.userId;
                // controller.userNameReceiver =
                //     data.toUser?.displayName ?? '';
                // controller.userNameSender =
                //     data.fromUser?.displayName ?? '';
                // controller.userIDReceiver =
                //     data.toUser?.userId;
                // controller.replyToMessage =data;
              },),
              binding: BindingsBuilder(() {
                Get.put(GalleryViewerController(
                    urls: controller.profileMediaList.map((v)=>"${ApiEnd.baseUrlMedia}${v.fileName??''}").toList(), index: i,
                    chathis: ChatHisList()));
              }),
              fullscreenDialog: true,
              transition: Transition.fadeIn,
            );
          },
          child: CustomCacheNetworkImage(
            url,
            height: double.infinity,
            width: double.infinity,
            borderWidth: 3,
            boxFit: BoxFit.cover,
            borderColor: Colors.red,
            radiusAll: 8,
          ),
        );
      },
    );
  }
}*/

class _DocsList extends StatelessWidget {
  final String baseUrl;
  final List<Items> items;
  final  controller;
  const _DocsList({required this.baseUrl, required this.items,required this.controller});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(child: Text('No documents found', style: BalooStyles.baloonormalTextStyle()));
    }
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          image: DecorationImage(image: AssetImage(appbarBG),fit: BoxFit.cover)
      ),
      child: ListView.separated(
        padding: EdgeInsets.only(top: 15),
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        controller: controller.scrollController2,
        separatorBuilder: (_, __) => Divider(color: Colors.grey.shade300, height: 1),
        itemBuilder: (_, i) {
          final d = items[i];
          final url = '$baseUrl${d.fileName ?? ''}';
          final name = (d.fileName ?? '').split('/').last;
          final ext = name.split('.').last.toUpperCase();
          final orgName = d.orgFileName??'';
          return HoverGlassEffect(
            margin: const EdgeInsets.symmetric(horizontal:kIsWeb ?25:12, vertical: kIsWeb ?4:2),
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            borderRadius: 12,
            hoverScale: 1.015,
            normalBlur: 3,
            hoverBlur: 10,
            gradient:  LinearGradient(colors: [
              gallwhite,
              Colors.white.withOpacity(.8),
            ]),
            child: ListTile(
              enabled: false,
              leading: const Icon(Icons.insert_drive_file_outlined),
              title: Text(orgName, maxLines: 1, overflow: TextOverflow.ellipsis, style: BalooStyles.baloonormalTextStyle()),
              subtitle: Text((d.mediaType?.name ?? 'Document') + (d.source != null ? ' · ${d.source}' : ''),
                style: BalooStyles.baloonormalTextStyle(size: 12, color: Colors.black54),
              ),
              trailing: const Icon(Icons.open_in_new),
              onTap: () { openDocumentFromUrl(url);},
            ),
          );
        },
      ),
    );
  }
}
