
import 'package:get/get.dart';

class StoryChatViewController extends GetxController {

  // final storyController = StoryController();
  //
  //
  // List<StoryItem>? storyItems = [];
  // ChatStoryDataModal? storyItem;

  @override
  void onInit() {

   /* storyItem=   Get.arguments[RoutesArgument.chatUserItemKey];
    storyItems = [

      customStoryItem(
        url:  storyItem?.storyLink??"",

        duration:Duration(seconds:getDurationIntSec ( storyItem?.storyDuration)) ,
        topView:    Container(
          height: 60,

          margin: EdgeInsets.only(top: margin_60),
          width: Get.width,
          alignment: Alignment.centerLeft,
          child: _topRowWidget(Get.context!,timeAgo: storyItem?.timesAgo??"",),
        ),



        controller: storyController,
        shown:  false,

      )
    ];*/

    super.onInit();
  }





/* Widget _topRowWidget(context,{String? timeAgo}) {
    return

      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomCacheNetworkImage(
            storyItem?.postedBy?.profileImageLink??"",
            height: margin_40,
            withBaseUrl: false,
            width: margin_40,
            radiusAll: margin_40,
          ),
          hGap(15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              vGap(5),
              Text(

                  storyItem?.postedBy?.name??"",
                  textAlign: TextAlign.center,
                  style: Styles.boldTextStyle(
                      color: Colors.white,
                      size: font_20
                  )),
              vGap(5),


            ],
          ),
          Spacer(),

          GetInkWell(
            onTap: () {
              print("back press");
              Get.back();
            },
            child: Icon(
              Icons.close,
              size: height_25,
              color: Colors.white,
            ),
          )
        ],
      )
          .marginSymmetric(horizontal: margin_20);
  }
*/




}





