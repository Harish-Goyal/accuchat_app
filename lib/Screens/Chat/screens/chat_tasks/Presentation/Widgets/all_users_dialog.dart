import 'package:AccuChat/Constants/assets.dart';
import 'package:AccuChat/Screens/Chat/api/apis.dart';
import 'package:AccuChat/Screens/Chat/models/task_res_model.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/all_user_controller.dart';
import 'package:AccuChat/Services/APIs/api_ends.dart';
import 'package:AccuChat/utils/networl_shimmer_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../Constants/colors.dart';
import '../../../../../../utils/helper_widget.dart';
import '../../../../../../utils/text_style.dart';

class AllUserScreenDialog extends GetView<AllUserController> {
   AllUserScreenDialog({super.key,this.users});

  List<TaskMember>? users;

  AllUserController controller  = Get.put(AllUserController());
   DateTime _lastCall = DateTime.fromMillisecondsSinceEpoch(0);

   bool canFetch() {
     final now = DateTime.now();
     if (now.difference(_lastCall).inMilliseconds < 300) return false;
     _lastCall = now;
     return true;
   }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 450,
        ),
        child:  Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                     Obx(()=> Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            controller.isSearching.value
                                ? Expanded(

                                    child: TextField(
                                      controller: controller.searchController,
                                      cursorColor: appColorGreen,
                                      decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          hintText: 'Search User...',
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 0, horizontal: 10),
                                          constraints: BoxConstraints(maxHeight: 45)),
                                      autofocus: true,
                                      style: const TextStyle(
                                          fontSize: 13, letterSpacing: 0.5),
                                      onChanged: (val) {
                                        controller.searchText = val;
                                        controller.onSearch(val);
                                      },
                                    ).marginSymmetric(vertical: 10),
                                  )
                                : Expanded(
                                    child: const Text(
                                      'Forwarded to',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ).paddingOnly(left: 8, top: 10),
                                  ),
                             IconButton(
                                  onPressed: () {
                                    controller.isSearching.value = !controller.isSearching.value;
                                    controller.isSearching.refresh();
                                    if(!controller.isSearching.value){
                                      controller.searchText = '';
                                      controller.onSearch('');
                                      controller.searchController.clear();
                                    }
                                  },
                                  icon: Icon(
                                    controller.isSearching.value
                                        ? CupertinoIcons.clear_circled_solid
                                        : Icons.search,
                                    color: colorGrey,
                                  )),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.8,
                        child: Obx((){
                          final selectedIds = users?.map((m) => m.userCompanyId).toSet();
                          final listToShow =(users??[]).isEmpty?controller.filteredList: controller.filteredList.where(
                                (u) => !selectedIds!.contains(u.userCompany?.userCompanyId??0),
                          ).toList();
                          return NotificationListener<ScrollNotification>(
                            onNotification: (ScrollNotification n) {
                              if (n is! ScrollEndNotification) return false;
                  
                              final m = n.metrics;
                  
                              if (m.extentAfter < 200 &&
                                  !controller.isLoading.value &&
                                  controller.hasMore &&
                                  canFetch()) {
                                controller.hitAPIToGetMember();
                              }
                              return false;
                            },
                            child: ListView.builder(
                              itemCount: listToShow.length,
                              controller: controller.scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemBuilder: (_, i) {
                               final memData = listToShow[i];
                                return
                                  ListTile(
                                    leading: SizedBox(
                                      width: 45,
                                      child: CustomCacheNetworkImage(
                                        "${ApiEnd.baseUrlMedia}${listToShow[i]
                                            .userImage ?? ''}",
                                        height: 45,
                                        width: 45,
                                        radiusAll: 100,
                                        boxFit: BoxFit.cover,
                                        borderColor: greyText,
                                        defaultImage: listToShow[i].userCompany
                                            ?.isGroup == 1 ? groupIcn :
                                        listToShow[i].userCompany?.isBroadcast ==
                                            1 ?
                                        broadcastIcon
                                            : userIcon,
                                      ),
                                    ),
                                    title:
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      children: [
                                        Text(
                                          memData.userId ==
                                              APIs.me?.userId
                                              ? "Me":   memData.userName != null ? memData
                                              .userName ?? '' : memData
                                              .userCompany?.displayName != null
                                              ? memData.userCompany
                                              ?.displayName ?? ''
                                              : memData.phone ?? '',
                                          style: BalooStyles
                                              .baloosemiBoldTextStyle(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                  
                                        vGap(4),
                                        memData.userName==null && memData.userCompany?.displayName==null?const SizedBox():  Text(
                                          memData.phone != null
                                              ?memData.phone ?? ''
                                              : memData.email ?? '',
                                          style: BalooStyles.balooregularTextStyle(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        )
                                      ],
                                    ),
                                    onTap: () {
                                      Navigator.pop(context, listToShow[i]);
                                    },
                                  );
                              }),
                          );
                                }
                  
                        ),
                      )
                    ],
                  ).paddingAll(15),
                ),
              )
      ),
    );
  }
}
