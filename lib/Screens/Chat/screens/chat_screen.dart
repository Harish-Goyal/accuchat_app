import 'dart:async';
import 'dart:io';
import 'package:AccuChat/utils/loading_indicator.dart';
import 'package:AccuChat/utils/networl_shimmer_image.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:AccuChat/Constants/themes.dart';
import 'package:AccuChat/Extension/text_field_extenstion.dart';
import 'package:AccuChat/Screens/Chat/screens/task_treads_screen.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/home_controller.dart';
import 'package:AccuChat/main.dart';
import 'package:AccuChat/utils/helper_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swipe_to/swipe_to.dart';
import '../../../Constants/app_theme.dart';
import '../../../Constants/assets.dart';
import '../../../Constants/colors.dart';
import '../../../utils/common_textfield.dart';
import '../../../utils/custom_dialogue.dart';
import '../../../utils/custom_flashbar.dart';
import '../../../utils/gradient_button.dart';
import '../../../utils/text_style.dart';
import '../api/apis.dart';
import '../helper/my_date_util.dart';
import '../models/chat_user.dart';
import '../models/message.dart';
import '../widgets/message_card.dart';
import 'view_profile_screen.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  final Message? forwardMessage;
  ChatScreen({super.key, required this.user, this.forwardMessage});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> _list = [];
  final _textController = TextEditingController();
  Message? _replyToMessage;
  bool _showEmoji = false, _isUploading = false, _isUploadingTaskDoc = false;
  File? _file;

  @override
  void initState() {
    super.initState();
  }
  List<Message> _allTasks = [];     // all fetched tasks
  List<Message> _filteredTasks = []; // after applying filter
  String _selectedFilter = 'all';


  void _applyTaskFilter(String filter, {bool fromStream=false}) {
    print(_allTasks.length);
    if (!fromStream) customLoader.show();
    _selectedFilter = filter;
    _filteredTasks.clear();

    if (filter == 'all') {
      _filteredTasks = _allTasks;
    } else if (['Pending', 'Running', 'Done', 'Cancelled','Completed']
        .contains(filter)) {
      _filteredTasks = _allTasks.where((msg) =>
      msg.taskDetails?.taskStatus == filter)
          .toList();
    } else {
      final now = DateTime.now();

      _filteredTasks = _allTasks.where((msg) {
        final createdAt = msg.createdAt ?? '0';
        final dt = DateTime.fromMillisecondsSinceEpoch(int.tryParse(createdAt) ?? 0);
        if (dt == null) return false;

        if (filter == 'today') {
          return dt.year == now.year && dt.month == now.month && dt.day == now.day;
        } else if (filter == 'week') {
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          final endOfWeek = startOfWeek.add(const Duration(days: 6));
          return dt.isAfter(startOfWeek) && dt.isBefore(endOfWeek);
        } else if (filter == 'month') {
          return dt.year == now.year && dt.month == now.month;
        }
        return false;
      }).toList();
    }
    if (!fromStream) {
      customLoader.hide();
      setState(() {});
    }
  }



  timeExceed(taskDetails) {
    Timer.periodic(Duration(seconds: 15), (timer) {
      final end = DateTime.fromMillisecondsSinceEpoch(taskDetails['estimatedEndTime']);
      if (DateTime.now().isAfter(end) && taskDetails['status'] != 'Done') {
        // play sound or show badge
        // _showDeadlineExceededAlert();
        timer.cancel();
      }
    });
  }

  final _tasksFormKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  bool isTaskMessage(String msg) {
    return msg.toLowerCase().startsWith('task:');
  }

  Map<String, dynamic>? parseTaskMessage(String msg) {
    if (!isTaskMessage(msg)) return null;

    final lines = msg.split('\n');
    final title = lines.first.replaceFirst('task:', '').trim();
    final timeLine =
        lines.last.toLowerCase().startsWith('time:') ? lines.last : null;
    final description = lines
        .sublist(1, timeLine != null ? lines.length - 1 : null)
        .join('\n')
        .trim();

    return {
      'title': title,
      'description': description,
      'time': timeLine?.replaceFirst('time:', '').trim()
    };
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          //if emojis are shown & back button is pressed then hide emojis
          //or else simple close current screen on back button click
          onWillPop: () {
            if (_showEmoji) {
              setState(() => _showEmoji = !_showEmoji);
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: SafeArea(
            child: Scaffold(
              //app bar
              appBar: AppBar(
                backgroundColor: Colors.white,
                automaticallyImplyLeading: false,
                flexibleSpace: _appBar(),
              ),
            
              backgroundColor: const Color.fromARGB(255, 234, 248, 255),
            
              //body
              body: Column(
                children: [
            
                  !isTaskMode
                      ? Expanded(
                          child: StreamBuilder(
                            stream: APIs.getOnlyChatMessages(widget.user.id),
                            builder: (context, snapshot) {
                              switch (snapshot.connectionState) {
                                //if data is loading
                                case ConnectionState.waiting:
                                case ConnectionState.none:
                                  return const SizedBox();
            
                                //if some or all data is loaded then show it
                                case ConnectionState.active:
                                case ConnectionState.done:
                                  final data = snapshot.data?.docs;
                                  _list = data
                                          ?.map((e) => Message.fromJson(e.data()))
                                          .toList() ??
                                      [];
                                  // _allTasks = _list;
                                  // List<Message> tasksToShow = _selectedFilter == 'all' ? _list : _filteredTasks;
                                  if (_list.isNotEmpty) {
                                    return ListView.builder(
                                        reverse: true,
                                        itemCount: _list.length,
                                        padding:
                                            EdgeInsets.only(top: mq.height * .02),
                                        physics: const BouncingScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          return SwipeTo(
                                            onRightSwipe: (detail) {
                                              _replyToMessage = _list[index];
                                              setState(() {});
                                            },
                                            child:
                                                MessageCard(
                                              message: _list[index],
                                              senderName: widget.user.name,
                                              isGroupMessage: false,
                                              fromId: widget.user.id,
                                              isTask:
                                              _list[index].isTask ?? false,
                                                  user: widget.user,
                                            ),
                                          );
                                        });
                                  } else {
                                    return Center(
                                      child: Text('Say Hii! 👋',
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: AppTheme.appColor)),
                                    );
                                  }
                              }
                            },
                          ),
                        )
                      : Expanded(
                    child: StreamBuilder(
                      stream: APIs.getOnlyTaskMessages(widget.user.id),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                        //if data is loading
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                            return const SizedBox();
            
                        //if some or all data is loaded then show it
                          case ConnectionState.active:
                          case ConnectionState.done:
                            // final data = snapshot.data?.docs;
                            // _list = data
                            //     ?.map((e) => Message.fromJson(e.data()))
                            //     .toList() ??
                            //     [];
                            // _allTasks = _list;
            
            
                            final data = snapshot.data?.docs;
                            _list = data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
                            for (var msg in _list) {
                              print("🔍 Message: ${msg.msg}, isTask: ${msg.isTask}");
                            }
                            // Only task messages
                            _allTasks = _list;
            
                            // 👉 Call filter function here (but avoid loader here!)
                            _applyTaskFilter(_selectedFilter, fromStream: true);
                            List<Message> tasksToShow = _selectedFilter == 'all' ? _allTasks : _filteredTasks;
            
                            if (tasksToShow.isNotEmpty) {
                              return ListView.builder(
                                  reverse: true,
                                  shrinkWrap: true,
                                  itemCount: tasksToShow.length,
                                  padding:
                                  EdgeInsets.only(top: mq.height * .04),
                                  physics: const BouncingScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return SwipeTo(
                                      onRightSwipe: (detail) {
                                        // _replyToMessage = tasksToShow[index];
                                        // setState(() {});
                                        if (index < tasksToShow.length) {
                                          // _replyToMessage = tasksToShow[index];
                                          setState(() {});
                                        }
                                        Get.to(()=>TaskThreadScreen(taskMessage:  tasksToShow[index] , currentUser: widget.user));
                                      },
                                      child:
                                      MessageCard(
                                        message: tasksToShow[index],
                                        senderName: widget.user.name,
                                        isGroupMessage: false,
                                        fromId: widget.user.id,
                                        user: widget.user,
                                        isTask:
                                        tasksToShow[index].isTask ?? false,
                                       )
                                    );
                                  });
                            } else {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text("No Task Found!",style: BalooStyles.balooboldTextStyle(color: appColorGreen),),
                                    Image.asset(emptyTask,height: 80,),
                                  ],
                                ),
                              );
                            }
                        }
                      },
                    ),
                  )
            
                  /*Expanded(
                          child: StreamBuilder(
                            stream: APIs.getOnlyTaskMessages(widget.user.id),
                            builder: (context, snapshot) {
                              switch (snapshot.connectionState) {
                                //if data is loading
                                case ConnectionState.waiting:
                                case ConnectionState.none:
                                  return const SizedBox();
            
                                //if some or all data is loaded then show it
                                case ConnectionState.active:
                                case ConnectionState.done:
                                  final data = snapshot.data?.docs;
                                  _list = data
                                          ?.map((e) => Message.fromJson(e.data()))
                                          .toList() ??
                                      [];
            
                                  if (_list.isNotEmpty) {
                                    return ListView.builder(
                                        reverse: true,
                                        itemCount: _list.length,
                                        padding:
                                            EdgeInsets.only(top: mq.height * .01),
                                        physics: const BouncingScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          return SwipeTo(
                                            onRightSwipe: (detail) {
                                              _replyToMessage = _list[index];
                                              setState(() {});
                                            },
                                            child:
                                                */
                  /*(_list[index].isTask == true && _list[index].taskDetails != null )
                                   ? _buildTaskCard(_list[index]):*/
                  /*
                                                MessageCard(
                                              message: _list[index],
                                              senderName: "",
                                              isGroupMessage: false,
                                              fromId: '',
                                              isTask:
                                                  _list[index].isTask ?? false,
                                            ),
                                          );
                                        });
                                  } else {
                                    return Center(
                                      child: Text('Say Hii! 👋',
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: AppTheme.appColor)),
                                    );
                                  }
                              }
                            },
                          ),
                        )*/,
                  //progress indicator for showing uploading
            
                  //chat input filed
                  if (_replyToMessage != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 4, left: 8, right: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(.2),
                        border: Border.all(color: lightgreyText),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.reply, color: appColorGreen),
                          const SizedBox(width: 8),
                          Expanded(
                            child:
                            (_replyToMessage!.type == Type.image)? Text(
                              "${_replyToMessage!.originalSenderName}: ${extractFileNameFromUrl(_replyToMessage?.msg??'')}",
                              style: themeData.textTheme.bodySmall?.copyWith(
                                color:  getTaskStatusColor(
                                    _replyToMessage!.taskDetails?.taskStatus)
                                    .withOpacity(.2),
                                fontStyle: FontStyle.italic,
                              ),
                            ):(_replyToMessage!.type == Type.doc)? Text(
                              "${_replyToMessage!.originalSenderName}: ${extractFileNameFromUrl(_replyToMessage?.msg??'')}",
                              style: themeData.textTheme.bodySmall?.copyWith(
                                color:  getTaskStatusColor(
                                    _replyToMessage!.taskDetails?.taskStatus)
                                    .withOpacity(.2),
                                fontStyle: FontStyle.italic,
                              ),
                            ):(_replyToMessage!.type == Type.text)?
                            Text(
                              "${_replyToMessage!.fromId == APIs.user.uid ? 'You' : widget.user.name}: ${_replyToMessage!.msg}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: themeData.textTheme.bodySmall
                                  ?.copyWith(color: greyText),
                            ):SizedBox(),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: blueColor,
                            ),
                            onPressed: () =>
                                setState(() => _replyToMessage = null),
                          )
                        ],
                      ),
                    ),
                  if (_isUploading)
                    const Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                            padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                            child: CircularProgressIndicator(strokeWidth: 2))),
                  _chatInput(),
                  //show emojis on keyboard emoji button click & vice versa
                  // if (_showEmoji)
                  // SizedBox(
                  //   height: mq.height * .35,
                  //   child: EmojiPicker(
                  //     textEditingController: _textController,
                  //     config: Config(
                  //       bgColor: const Color.fromARGB(255, 234, 248, 255),
                  //       columns: 8,
                  //       emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                  //     ),
                  //   ),
                  // )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String validString ='';
  List<Map<String, String>> _uploadedAttachments = [];
  _createTasksDialogWidget(userName) {
    return StatefulBuilder(
      builder: (context,setStateInside) {
        return CustomDialogue(
          title: "Create Task for ${widget.user.id==APIs.me.id?'You':userName=='null'?widget.user.phone:userName}",
          isShowAppIcon: false,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Enter Task Details",
                style: BalooStyles.baloonormalTextStyle(),
                textAlign: TextAlign.center,
              ),
              Text(
                validString,
                style: BalooStyles.baloonormalTextStyle(color: AppTheme.redErrorColor),
                textAlign: TextAlign.center,
              ),
              vGap(10),
              _taskInputArea(setStateInside),
              vGap(10),
              Text("Attachments", style: TextStyle(fontWeight: FontWeight.bold)),
              vGap(10),
              if(_isUploadingTaskDoc)
                IndicatorLoading(),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _attachedFiles.map((file) {
                  final String type = file['type'];
                  final String name = file['name'];
                  final String url = file['url'];

                  Widget preview;

                  if (type == 'image') {
                    preview = CustomCacheNetworkImage(
                      url,
                      radiusAll: 8,
                      boxFit: BoxFit.cover,
                      defaultImage: defaultGallery,
                    );
                  } else if (type == 'doc') {
                    IconData icon;
                    if (name.endsWith('.pdf')) {
                      icon = Icons.picture_as_pdf;
                    } else if (name.endsWith('.doc') || name.endsWith('.docx')) {
                      icon = Icons.description;
                    } else if (name.endsWith('.txt')) {
                      icon = Icons.note;
                    } else {
                      icon = Icons.insert_drive_file;
                    }

                    preview = Container(
                      width: 75,
                      height: 75,
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(icon, size: 30, color: Colors.grey),
                          Text(name, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10)),
                        ],
                      ),
                    );
                  } else {
                    preview = const SizedBox();
                  }

                  return Stack(
                    alignment: Alignment.topRight,
                    clipBehavior: Clip.none,
                    children: [
                      preview,
                      Positioned(
                        top: -5,
                        right:-5,
                        child: GestureDetector(
                          onTap: () {
                            setStateInside(() {
                              _attachedFiles.remove(file);
                            });
                            setState(() {

                            });
                          },
                          child: const CircleAvatar(
                            radius: 13,
                            backgroundColor: Colors.red,
                            child: Icon(Icons.close, size: 12, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),

              vGap(10),

              GestureDetector(
                onTap: ()=>
                 _attachedFiles.length<3?   showUploadOptionsForTask(context,setStateInside):toast("You can upload upto 3 attachments only"),
                child: const Chip(
                  avatar: Icon(Icons.attach_file),
                  label: Text("Add Attachments"),
                ),
              ),



              vGap(20),
              GradientButton(
                name: "Send Task to ${widget.user.id==APIs.me.id?'You':userName=='null'?widget.user.phone:userName}",
                btnColor: AppTheme.appColor,
                vPadding: 8,
                onTap: () {
                  if (_tasksFormKey.currentState!.validate()) {
                      if(_getEstimatedTime(setStateInside) !=  ""  && _selectedDate!=null && _selectedTime!=null){
                        if(_getEstimatedTime(setStateInside) == "Oops! The selected time is in the past. Please choose a valid future time."){
                          setStateInside(() {
                            validString = "Please select valid time check AM PM correctly";
                          });
                        }else{
                          if(!_isUploadingTaskDoc) {
                            _handleSendPressed(setStateInside);
                          }else{
                            toast("Please wait");
                          }
                        }
                      }else{
                        if(!_isUploadingTaskDoc) {
                          _handleSendPressed(setStateInside);
                        }else{
                          toast("Please wait");
                        }
                      }
                  }
                },
              )
            ],
          ),
          onOkTap: () {},
        );
      }
    );
  }
  List<Map<String, dynamic>> _attachedFiles = [];

  Widget _buildFileChip(File file) {
    final ext = file.path.split('.').last.toLowerCase();
    IconData icon;
    if (ext == 'pdf') icon = Icons.picture_as_pdf;
    else if (ext == 'doc' || ext == 'docx') icon = Icons.description;
    else if (ext == 'txt') icon = Icons.text_snippet;
    else icon = Icons.insert_drive_file;

    return Chip(
      avatar: Icon(icon),
      label: Text(file.path.split('/').last),
      onDeleted: () => setState(() => _attachedFiles.remove(file)),
    );
  }

  Widget _taskInputArea(setStateInside) {
    return Form(
        key: _tasksFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTaskField("Title", _titleController, 1, 50),
            vGap(15),
            _buildTaskField("Description", _descController, 5, 300),
            vGap(8),
            InkWell(
              onTap: () async {
                _showDateTimePicker(setStateInside);
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8,horizontal: 12),
                decoration: BoxDecoration(
                  color: appColorGreen.withOpacity(.1),
                  borderRadius: BorderRadius.circular(12)
                ),
                child: Row(
                  // mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        // Text(
                        //   "Selected Time: ${_selectedTime?.format(context) ?? 'Not selected'}",
                        //   style: const TextStyle(fontSize: 14),
                        // )

                        (_selectedDate != null && _selectedTime != null)
                            ? "Est. Time : ${_getEstimatedTime(setStateInside)}"
                            : "Select task deadline",
                        style: themeData.textTheme.bodySmall?.copyWith(
                          color:_getEstimatedTime(setStateInside)== "Oops! The selected time is in the past. Please choose a valid future time."?
                              AppTheme.redErrorColor:Colors.black
                        ),
                      ).paddingAll(5),
                    ),

                   Icon(
                        Icons.access_time,
                        color: appColorGreen,
                      ).paddingOnly(right: 5, top: 5),

                  ],
                ),
              ),
            ),
          ],
        ),
      );
  }

  _showDateTimePicker(setStateInside) async {
    // Pick Date
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setStateInside(() {
        _selectedDate = pickedDate;
      });
      // setState(() => _selectedDate = pickedDate);
    }

// Pick Time
//     final pickedTime = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setStateInside(() {
        _selectedTime = picked;
      });
      // setState(() => _selectedTime = picked);
      print("⏰ Selected time: ${picked.format(context)}");
    }
    setStateInside(() {
      validString = "";
    });
    // if (pickedTime != null) {
    //   setState(() => _selectedTime = pickedTime);
    // }
  }


  Widget _buildTaskField(
      String label, TextEditingController controller, maxLine, maxL) {
    return CustomTextField(
      controller: controller,
      labletext: label,
      hintText: label,

      minLines: maxLine,
      maxLines: maxLine,
      validator: (value) {
        return value?.isEmptyField(messageTitle: label);
      },
      // maxLength: maxL,
    );
  }

  String _getEstimatedTime(setStateInside) {
  /*  if (_selectedTime == null) return "";

    final now = DateTime.now();

    // You can also include selectedDate if you allow full date selection
    final selectedDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final duration = selectedDateTime.difference(now);

    if (duration.isNegative) return "⏰ Time exceeded!";

    final hrs = duration.inHours;
    final mins = duration.inMinutes.remainder(60);

    return "⏳ $hrs hrs ${mins} mins";*/

    if (_selectedDate == null || _selectedTime == null) return "";

    final selectedDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final now = DateTime.now();
    final duration = selectedDateTime.difference(now);

    if (duration.isNegative) return "Oops! The selected time is in the past. Please choose a valid future time.";

    final hrs = duration.inHours;
    final mins = duration.inMinutes.remainder(60);
    return "⏳ $hrs hrs $mins mins remaining";
  }




  void _handleSendPressed(setStateInside) async {
    customLoader.show();
    DateTime? selectedDateTime;

    if(_selectedDate!=null&&_selectedTime!=null) {
         selectedDateTime = DateTime(
           _selectedDate!.year,
           _selectedDate!.month,
           _selectedDate!.day,
           _selectedTime!.hour,
           _selectedTime!.minute,
         );
       }
        var title = _titleController.text ?? 'Task';
        var description = _descController.text ?? '';
        var time = selectedDateTime?.millisecondsSinceEpoch.toString();
        final now = DateTime.now().toIso8601String();
        if (_list.isEmpty) {
          //on first message (add user to my_user collection of chat user)
           APIs.sendFirstMessage(
            widget.user, _textController.text, Type.text,
            // replyToMsg: _replyToMessage?.msg,
            // replyToSenderName: _replyToMessage?.fromId == APIs.me.id ? 'You' : widget.user.name,
            // replyToType: _replyToMessage?.type,
            isTask: isTaskMode,
            taskDetails: TaskDetails(
                title: title,
                description: description,
                estimatedTime: time ?? '0',
                startTime: '',
                endTime: '',
                attachments: _attachedFiles,
                taskStatus: TaskStatus.Pending.name),
                taskStartTime: time != null ? now : null,

          ).whenComplete(()async{
            _textController.clear();
            _descController.clear();
            _titleController.clear();
            _attachedFiles.clear();
            _replyToMessage = null;
            _selectedTime = null;
            _selectedDate = null;
            setState(() {});
            setStateInside(() {});

             APIs.updateTypingStatus(false);
            customLoader.hide();
            Get.back();});
        }

        else {
          //simply send message
           APIs.sendMessage(
            widget.user,
            _textController.text,
            Type.text,
            replyToMsg: _replyToMessage?.msg ?? '',
            replyToSenderName: _replyToMessage?.fromId == APIs.me.id
                ? 'You'
                : widget.user.name,
            replyToType: _replyToMessage?.type,
            isTask: isTaskMode,
            taskDetails: TaskDetails(
                title: title,
                description: description,
                estimatedTime: time ?? '0',
                startTime: '',
                endTime: '',
                attachments: _attachedFiles,
                taskStatus: TaskStatus.Pending.name),
            taskStartTime:"",
          ).whenComplete(()async{
            _textController.clear();
            _replyToMessage = null;
            setState(() {});
            setStateInside(() {});

              APIs.updateTypingStatus(false);
            customLoader.hide();
            Get.back();});
        }



  }

  Map<String, dynamic>? _extractTaskDetails(String message) {
    final taskRegex = RegExp(r'task:\s*(.+)', caseSensitive: false);
    final timeRegex = RegExp(r'time:\s*(.+)', caseSensitive: false);

    final taskMatch = taskRegex.firstMatch(message);
    final timeMatch = timeRegex.firstMatch(message);

    if (taskMatch != null) {
      return {
        'title': taskMatch.group(1)?.trim() ?? '',
        'description': message,
        'estimatedTime': timeMatch?.group(1)?.trim() ?? ''
      };
    }

    return null;
  }

  DashboardController dashboardController = Get.put(DashboardController());

  // app bar widget
  Widget _appBar() {
    return InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ViewProfileScreen(user: widget.user)));
          APIs.updateActiveStatus(false);
        },
        child: StreamBuilder(
            stream: APIs.getUserInfo(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

              return Container(
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          //back button
                          IconButton(
                              onPressed: () {
                                Get.back();
                                if(isTaskMode){
                                  dashboardController.updateIndex(2);
                                }else{
                                  dashboardController.updateIndex(1);
                                }

                                APIs.updateActiveStatus(false);
                              },
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.black54)),
                      
                          //user profile picture
                          SizedBox(
                            width: mq.height * .055,
                            child: CustomCacheNetworkImage(
                              radiusAll: 100,
                                          list.isNotEmpty ? list[0].image : widget.user.image,
                              height: mq.height * .055,
                            width: mq.height * .055,
                            boxFit: BoxFit.cover,
                            defaultImage: ICON_profile,
                            ),
                          ),
                      
                          //for adding some space
                          const SizedBox(width: 10),
                      
                          //user name & last seen time
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //user name


                              list.isNotEmpty?    list[0].name.isEmpty||list[0].name==''||list[0].name==null||list[0].name=='null'?
                              Text(list[0].phone,maxLines: 1,overflow: TextOverflow.ellipsis,style: themeData.textTheme.titleMedium,):
                              Text(list[0].name??'User',maxLines: 1,overflow: TextOverflow.ellipsis,style: themeData.textTheme.titleMedium,):SizedBox(),
                              // Text(list.isNotEmpty ? list[0].name : widget.user.name,
                              //     style: const TextStyle(
                              //         fontSize: 16,
                              //         color: Colors.black87,
                              //         fontWeight: FontWeight.w500)),
                      
                              //for adding some space
                              const SizedBox(height: 2),
                      
                              //last seen time of user
                              Text(
                                  list.isNotEmpty
                                      ? list[0].isOnline && !list[0].isTyping
                                          ? 'Online'
                                          : list[0].isTyping && list[0].isOnline
                                              ? "Typing..."
                                              : MyDateUtil.getLastActiveTime(
                                                  context: context,
                                                  lastActive:
                                                      list[0].lastActive.toString())
                                      : MyDateUtil.getLastActiveTime(
                                          context: context,
                                          lastActive:
                                              widget.user.lastActive.toString()),
                                  style: const TextStyle(
                                      fontSize: 13, color: Colors.black54)),
                            ],
                          ),
                          
                        ],
                      ),
                    ),



                   !isTaskMode?SizedBox():
                     PopupMenuButton<String>(
                       color: Colors.white,
                       icon: const Icon(Icons.filter_alt_outlined,color: Colors.black87,),
                       onSelected: (value) {
                         _applyTaskFilter(value);
                       },
                       itemBuilder: (context) => [
                         const PopupMenuItem(value: 'all', child: Text('All Tasks')),
                         const PopupMenuDivider(),
                         const PopupMenuItem(value: 'Pending', child: Text('Pending')),
                         const PopupMenuItem(value: 'Running', child: Text('Running')),
                         const PopupMenuItem(value: 'Done', child: Text('Done')),
                         const PopupMenuItem(value: 'Cancelled', child: Text('Cancelled')),
                         const PopupMenuItem(value: 'Completed', child: Text('Completed')),
                         const PopupMenuDivider(),
                         const PopupMenuItem(value: 'today', child: Text('Today')),
                         const PopupMenuItem(value: 'week', child: Text('This Week')),
                         const PopupMenuItem(value: 'month', child: Text('This Month')),
                       ],
                     ),


                  ],
                ),
              );
            }));
  }

  bool isVisibleUpload = true;

  // bottom chat input field
  Widget _chatInput() {
    ThemeData themeData = Theme.of(context);
    return StreamBuilder(
        stream: APIs.getUserInfo(widget.user),
        builder: (context, snapshot) {
          final data = snapshot.data?.docs;
          final list =
              data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
          return Container(
            // height: Get.height*.4,
            padding: EdgeInsets.symmetric(
                vertical: mq.height * .01, horizontal: mq.width * .025),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                //input field & buttons
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      //emoji button
                      /* IconButton(
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            setState(() => _showEmoji = !_showEmoji);
                          },
                          icon: const Icon(Icons.emoji_emotions,
                              color: Colors.blueAccent, size: 25)),*/

                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                    maxHeight: Get.height * .4, minHeight: 40),
                                child: Container(
                                  // color: Colors.red,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppTheme.appColor.withOpacity(.2))
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _textController,
                                          keyboardType: TextInputType.multiline,
                                          cursorColor: AppTheme.appColor,
                                          maxLines: null,
                                          onChanged: (text) {
                                            if (text.isNotEmpty) {
                                              list[0].isTyping = true;
                                              APIs.updateTypingStatus(true);
                                              if(isVisibleUpload){
                                                setState(() {
                                                  isVisibleUpload = false;
                                                });
                                              }
                                            } else {
                                              list[0].isTyping = false;
                                              APIs.updateTypingStatus(false);
                                              if(!isVisibleUpload){
                                                setState(() {
                                                  isVisibleUpload = true;
                                                });
                                              }
                                            }
                                          },
                                          onTap: () {
                                            // if (_showEmoji)
                                            //   setState(() => _showEmoji = !_showEmoji);
                                        
                                            if (isTaskMode) {
                                              showDialog(
                                                      context: Get.context!,
                                                      builder: (_) =>
                                                          _createTasksDialogWidget(
                                                              widget.user.name))
                                                  .then((pickedTime) {
                                                if (pickedTime != null) {
                                                  setState(() {
                                                    // _selectedTime = pickedTime;
                                                  });
                                                }
                                              });
                                            }
                                          },
                                          decoration: InputDecoration(
                                              hintText: 'Type Something...',
                                              hintStyle: themeData.textTheme.bodySmall,
                                              contentPadding: const EdgeInsets.all(8),
                                              border: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            disabledBorder: InputBorder.none,
                                            errorBorder: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                          ),
                                        ),
                                      ),

                                      if (!isTaskMode)
                                        Visibility(
                                          visible: isVisibleUpload,
                                          child: InkWell(
                                            onTap: ()=>showUploadOptions(context),
                                            child: Icon(Icons.upload_outlined,color: Colors.black54,),
                                          ).paddingAll(3)
                                      )
                                    ],


                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),


                    ],
                  ),
                ),
                /*  hGap(6),
                Card(
                  clipBehavior: Clip.none,
                  color: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      //pick image from gallery button
                        IconButton(
                          onPressed: () async {
                            final ImagePicker picker = ImagePicker();

                            // Picking multiple images
                            final List<XFile> images =
                            await picker.pickMultiImage(imageQuality: 70);

                            // uploading & sending image one by one
                            for (var i in images) {
                              // log('Image Path: ${i.path}');
                              setState(() => _isUploading = true);
                              await APIs.sendChatImage(
                                  widget.user, File(i.path));
                              setState(() => _isUploading = false);
                            }
                          },
                          icon: const Icon(Icons.image,
                              color: Colors.blueAccent, size: 26)),

                      //take image from camera button
                      IconButton(
                          onPressed: () async {
                            // final ImagePicker picker = ImagePicker();
                            // // Pick an image
                            // final XFile? image = await picker.pickImage(
                            //     source: ImageSource.camera, imageQuality: 70);
                            // if (image != null) {
                            //   // log('Image Path: ${image.path}');
                            //   setState(() => _isUploading = true);
                            //
                            //   await APIs.sendChatImage(
                            //       widget.user, File(image.path));
                            //   setState(() => _isUploading = false);
                            // }
                            chooseMediaSource(context);
                          },
                          tooltip: "Choose image from Gallery or Camera",
                          padding: EdgeInsets.all(0),
                          splashRadius: 1,
                          icon: const Icon(Icons.camera_alt_outlined,
                              color: Colors.blueAccent, size: 26)),
                    ],
                  ),
                ),
                ,*/
                hGap(6),
                InkWell(
                  onTap: () async{
                    if (_textController.text.isNotEmpty) {
                      if(isTaskMode){
                      final selectedDateTime = DateTime(
                        _selectedDate!.year,
                        _selectedDate!.month,
                        _selectedDate!.day,
                        _selectedTime!.hour,
                        _selectedTime!.minute,
                      );
                      var title = _titleController.text ?? 'Task';
                      var description = _descController.text ?? '';
                      var time =
                          selectedDateTime.millisecondsSinceEpoch.toString();
                      final now = DateTime.now().toIso8601String();
                      if (_list.isEmpty) {
                        //on first message (add user to my_user collection of chat user)
                         APIs.sendFirstMessage(
                          widget.user, _textController.text, Type.text,
                          // replyToMsg: _replyToMessage?.msg,
                          // replyToSenderName: _replyToMessage?.fromId == APIs.me.id ? 'You' : widget.user.name,
                          // replyToType: _replyToMessage?.type,
                          isTask: isTaskMode,
                          taskDetails: TaskDetails(
                              title: title,
                              description: description,
                              estimatedTime: time ?? '0',
                              startTime: '',
                              endTime: '',
                              taskStatus: TaskStatus.Pending.name),
                          taskStartTime: time != null ? now : null,
                        );
                      } else {
                        //simply send message
                         APIs.sendMessage(
                          widget.user,
                          _textController.text,
                          Type.text,
                          replyToMsg: _replyToMessage?.msg ?? '',
                          replyToSenderName:
                          _replyToMessage?.fromId == APIs.me.id
                              ? 'You'
                              : widget.user.name,
                          replyToType: _replyToMessage?.type,
                          isTask: isTaskMode,
                          taskDetails: TaskDetails(
                              title: title,
                              description: description,
                              estimatedTime: time ?? '0',
                              startTime: '',
                              endTime: '',
                              taskStatus: TaskStatus.Pending.name),
                          taskStartTime: time != null ? now : null,
                        );
                      }
                      }

                      print("_list.length=====");
                      print(_list.length);
                      if (_list.isEmpty || _list.length == 0) {
                        //on first message (add user  to my_user collection of chat user)
                         APIs.sendFirstMessage(
                          widget.user, _textController.text, Type.text,
                          // replyToMsg: _replyToMessage?.msg,
                          // replyToSenderName: _replyToMessage?.fromId == APIs.me.id ? 'You' : widget.user.name,
                          // replyToType: _replyToMessage?.type,
                          isTask: isTaskMode,
                          taskDetails: TaskDetails.fromJson({}),
                          taskStartTime: null,
                        );
                      } else {
                        //simply send message
                        print("_list.length");
                        print(_list.length);
                          APIs.sendMessage(
                          widget.user,
                          _textController.text,
                          Type.text,
                          replyToMsg: _replyToMessage?.msg ?? '',
                          replyToSenderName:
                              _replyToMessage?.fromId == APIs.me.id
                                  ? 'You'
                                  : widget.user.name,
                          replyToType: _replyToMessage?.type,
                          isTask: isTaskMode,
                          taskDetails: TaskDetails.fromJson({}),
                          taskStartTime: null,
                        );
                      }
                      _textController.clear();
                      _replyToMessage = null;
                      setState(() {});

                       APIs.updateTypingStatus(false);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: appColorGreen,
                    ),
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                )
              ],
            ),
          );
        });
  }

  void showUploadOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 16,left: 15,right: 15,bottom: 60),
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text("Camera"),
                onTap: ()async {
                  Get.back();
                  final ImagePicker picker = ImagePicker();
                  // Pick an image
                  final XFile? image = await picker.pickImage(
                      source: ImageSource.camera, imageQuality: 50);
                  if (image != null) {
                    print('Image Path: ${image.path}');
                    setState(() => _isUploading = true);

                    await APIs.sendChatImage(
                        widget.user, File(image.path));
                    setState(() => _isUploading = false);
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.photo),
                title: Text("Gallery"),
                onTap: () async{
                  Get.back();
                  final ImagePicker picker = ImagePicker();

                  // Picking multiple images
                  final List<XFile> images =
                      await picker.pickMultiImage(imageQuality: 50);

                  // uploading & sending image one by one
                  for (var i in images) {
                    print('Image Path: ${i.path}');
                    setState(() => _isUploading = true);
                    await APIs.sendChatImage(
                        widget.user, File(i.path));
                    setState(() => _isUploading = false);
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.picture_as_pdf),
                title: Text("Document"),
                onTap: (){
                  Get.back();
                 _pickDocument();

                } ,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showUploadOptionsForTask(BuildContext context,setStateInside) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 16,left: 15,right: 15,bottom: 60),
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text("Camera"),
                onTap: ()async {
                  setStateInside(() {
                    _isUploadingTaskDoc =true;
                  });
                  Get.back();
                  final ImagePicker picker = ImagePicker();
                  // Pick an image
                  final XFile? image = await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
                  if (image != null) {
                    final file = File(image.path);
                    final fileName = 'IMG_${DateTime.now().millisecondsSinceEpoch}.jpg';
                    final ref = FirebaseStorage.instance.ref().child('media/tasks/$fileName');

                    await ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
                    final url = await ref.getDownloadURL();

                    setState(() {
                      _attachedFiles.add({'url': url, 'type': 'image', 'name': fileName});
                    });
                  }
                  setStateInside(() {
                    _isUploadingTaskDoc =false;
                  });
                },
              ),
              ListTile(
                leading: Icon(Icons.photo),
                title: Text("Gallery"),
                onTap: () async{
                  setStateInside(() {
                  _isUploadingTaskDoc = true; });
                  Get.back();
                  final ImagePicker picker = ImagePicker();

                  final List<XFile> images = await picker.pickMultiImage(imageQuality: 50,limit: 3);
                  final remainingSlots = 3 - _attachedFiles.length;
                  if (images.length > remainingSlots) {
                    images.removeRange(remainingSlots, images.length);
                  }
                  for (var i in images) {
                    final file = File(i.path);

                    final fileName = 'IMG_${DateTime.now().millisecondsSinceEpoch}.jpg';
                    final ref = FirebaseStorage.instance.ref().child('media/tasks/$fileName');

                    await ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
                    final url = await ref.getDownloadURL();

                    setStateInside(() {
                      _attachedFiles.add({'url': url, 'type': 'image', 'name': fileName});
                    });

                  }

                  setStateInside(() {
                    _isUploadingTaskDoc = false;
                  });

                },
              ),
              ListTile(
                leading: Icon(Icons.picture_as_pdf),
                title: Text("Document"),
                onTap: (){
                  Get.back();
                  !isTaskMode? _pickDocument():
                  _pickDocumentForTask(setStateInside);
                } ,
              ),
            ],
          ),
        ),
      ),
    );
  }

/*
  Future<void> requestStoragePermission({bool istask = false,setStateInside}) async {
    if (Platform.isAndroid && await Permission.manageExternalStorage.isGranted) {
      istask?_pickDocumentForTask(setStateInside):_pickDocument();
    } else if (Platform.isAndroid) {
      var result = await Permission.manageExternalStorage.request();
      if (result.isGranted) {
        istask?_pickDocumentForTask(setStateInside):_pickDocument();
      } else if (result.isPermanentlyDenied) {
        await openAppSettings();
      }else if (result.isDenied) {
        result= await Permission.manageExternalStorage.request();
      } else {
        print("❌ Storage permission denied again");
      }
    } else {
      // For iOS or other platforms
      final result = await Permission.storage.request();
      if (result.isGranted) {
        istask?_pickDocumentForTask(setStateInside):_pickDocument();
      } else {
        print("❌ Storage permission denied again");
      }
    }

  }
*/


  Future<void> _pickDocument() async {

    final permission = await requestStoragePermission();
    if (!permission) {
      print("❌ Storage permission denied");
      return;
    }
    setState(() {
      _isUploading = true;
    });
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf', 'doc', 'docx', 'txt',
        'xls', 'xlsx', 'csv', // Excel formats
        'xml', 'json', // markup/data formats
        // 'exe', 'apk', // executable formats (⚠️ be cautious)
        'ppt', 'pptx', // PowerPoint
        'zip', 'rar', // Archives
      ],
    );
    
    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      var ext = file.path.split('.').last;
      final fileName = 'DOC_${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}';
      final ref = FirebaseStorage.instance.ref().child('media/docs/$fileName');

      await ref.putFile(file,SettableMetadata(contentType: 'media/$ext'));
      final downloadURL = await ref.getDownloadURL();
      
       APIs.sendMessage(widget.user, downloadURL, Type.doc);
      setState(() {
        _isUploading = false;
      });
      print("✅ Document Uploaded: $downloadURL");
    }
  }

  Future<void> _pickDocumentForTask(setStateInside) async {
    setState(() {});
    setStateInside(() {
      _isUploadingTaskDoc = true;
    });


    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf', 'doc', 'docx', 'txt',
        'xls', 'xlsx', 'csv', // Excel formats
        'xml', 'json', // markup/data formats
        // 'exe', 'apk', // executable formats (⚠️ be cautious)
        'ppt', 'pptx', // PowerPoint
        'zip', 'rar', // Archives
      ],
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      var ext = file.path.split('.').last;
      final fileName = 'DOC_${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}';
      final ref = FirebaseStorage.instance.ref().child('media/tasks/$fileName');

      await ref.putFile(file, SettableMetadata(contentType: 'application/$ext'));
      final url = await ref.getDownloadURL();

      setState(() {
        _attachedFiles.add({'url': url, 'type': 'doc', 'name': result.files.single.name});
      });
      setStateInside(() {
        _isUploadingTaskDoc = false;
      });

    }
  }

  initVideoPlayer() async {
    // videoPlayerController = VideoPlayerController.file(_file!);
    // await videoPlayerController?.initialize();
    // chewieController = ChewieController(
    //   videoPlayerController: videoPlayerController!,
    //   autoPlay: false,
    //   showControls: false,
    //   aspectRatio: MediaQuery.of(context).size.aspectRatio * 2.74,
    // );
    // setState(() {});
  }

  chooseMediaSource(BuildContext context) async {
    var pFile;
    _galleryVideo() async {
      pFile = await ImagePicker.platform.pickVideo(
          source: ImageSource.gallery,
          maxDuration: const Duration(seconds: 30));
      if (pFile != null) {
        setState(() {
          _file = File(pFile.path);
          _isUploading = true;
        });

        await APIs.sendChatVideo(widget.user, File(pFile.path));
        await initVideoPlayer();
        setState(() => _isUploading = false);
      }
    }

    _gallaryImage() async {
      // final ImagePicker picker = ImagePicker();
      //
      // // Picking multiple images
      // final List<XFile> images = await picker.pickMultiImage(imageQuality: 70);
      //
      // // uploading & sending image one by one
      // for (var i in images) {
      //   // log('Image Path: ${i.path}');
      //   setState(() => _isUploading = true);
      //   await APIs.sendChatImage(widget.user, File(i.path));
      //   setState(() => _isUploading = false);
      // }
      final ImagePicker picker = ImagePicker();

      // Picking multiple images
      final List<XFile> images = await picker.pickMultiImage(imageQuality: 70);

      // uploading & sending image one by one
      for (var i in images) {
        // log('Image Path: ${i.path}');
        setState(() => _isUploading = true);
        await APIs.sendChatImage(widget.user, File(i.path));
        setState(() => _isUploading = false);
      }
    }

    _cameraVideo() async {
      pFile = await ImagePicker.platform.pickVideo(
          source: ImageSource.camera, maxDuration: const Duration(seconds: 30));
      print(pFile);
      if (pFile != null) {
        setState(() {
          _file = File(pFile.path);
          _isUploading = true;
        });
        print(_file?.path);

        await APIs.sendChatVideo(widget.user, File(pFile.path));
        await initVideoPlayer();
        setState(() => _isUploading = false);
      }
    }

    _cameraImage() async {
      // final ImagePicker picker = ImagePicker();
      // // Pick an image
      // final XFile? image =
      //     await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
      // if (image != null) {
      //   // log('Image Path: ${image.path}');
      //   setState(() => _isUploading = true);
      //
      //   await APIs.sendChatImage(widget.user, File(image.path));
      //   setState(() => _isUploading = false);
      // }

      final ImagePicker picker = ImagePicker();
      // Pick an image
      final XFile? image =
          await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
      if (image != null) {
        // log('Image Path: ${image.path}');
        setState(() => _isUploading = true);

        await APIs.sendChatImage(widget.user, File(image.path));
        setState(() => _isUploading = false);
      }
    }

    return showBottomSheet(
        context: context,
        builder: (_) => Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Gallery',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  /*const SizedBox(height: 5),
                  ListTile(
                    title: const Text('Video'),
                    leading: const Icon(Icons.video_collection_rounded),
                    onTap: () async {
                      await _galleryVideo();
                      Navigator.pop(context, _file);
                    },
                    contentPadding: const EdgeInsets.all(0),
                    isThreeLine: false,
                  ),*/
                  const SizedBox(height: 5),
                  ListTile(
                    title: const Text('Image'),
                    leading: const Icon(Icons.video_collection_rounded),
                    onTap: () async {
                      await _gallaryImage();
                      Navigator.pop(context, _file);
                    },
                    contentPadding: const EdgeInsets.all(0),
                    isThreeLine: false,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  const Text(
                    'Camera',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  /* ListTile(
                    title: const Text('Video'),
                    leading: const Icon(Icons.videocam_outlined),
                    onTap: () async {
                      await _cameraVideo();
                      Navigator.pop(context, _file);
                    },
                    contentPadding: const EdgeInsets.all(0),
                    isThreeLine: false,
                  ),
                  const SizedBox(height: 5),*/
                  ListTile(
                    title: const Text('Image'),
                    leading: const Icon(Icons.image),
                    onTap: () async {
                      await _cameraImage();
                      Navigator.pop(context, _file);
                    },
                    contentPadding: const EdgeInsets.all(0),
                    isThreeLine: false,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                ],
              ),
            ));
  }
}
