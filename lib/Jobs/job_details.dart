import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ijob_app/Jobs/jobs_screen.dart';
import 'package:ijob_app/Services/global_methods.dart';
import 'package:ijob_app/Services/global_variables.dart';
import 'package:ijob_app/Widgets/comments_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:uuid/uuid.dart';

class JobDetailsScreen extends StatefulWidget {

  final String uploadedBy;
  final String jobID;

  const JobDetailsScreen({
    required this.uploadedBy,
    required this.jobID,
});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _commentController = TextEditingController();

  bool _isCommenting = false;
  String? authorName;
  String? userImageUrl;
  String? jobCategory;
  String? jobDescription;
  String? jobTitle;
  bool? recruitment;
  Timestamp? postedDateTimeStamp;
  Timestamp? deadlineDateTimeStamp;
  String? postedDate;
  String? deadlineDate;
  String? locationCompany = '';
  String emailCompany = '';
  int applicants = 0;
  bool isDeadlineAvailable = false;
  bool showComment = false;

  void getJobData() async {
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uploadedBy)
        .get();

    if(userDoc == null){
      return;
    } else {
      setState((){
        authorName = userDoc.get('name');
        userImageUrl = userDoc.get('userImage');
      });
    }
    final DocumentSnapshot jobDatabase = await FirebaseFirestore.instance
        .collection('jobs')
        .doc(widget.jobID)
        .get();
    if(jobDatabase == null){
      return;
    } else {
      setState((){
        jobTitle = jobDatabase.get('jobTitle');
        jobDescription = jobDatabase.get('jobDescription');
        recruitment = jobDatabase.get('recruitment');
        emailCompany = jobDatabase.get('email');
        locationCompany = jobDatabase.get('location');
        applicants = jobDatabase.get('applicants');
        postedDateTimeStamp = jobDatabase.get('createdAt');
        deadlineDateTimeStamp = jobDatabase.get('deadlineDateTimeStamp');
        deadlineDate = jobDatabase.get('deadlineDate');
        var postDate = postedDateTimeStamp!.toDate();
        postedDate = '${postDate.year}-${postDate.month}-${postDate.day}';
      });

      var date = deadlineDateTimeStamp!.toDate();
      isDeadlineAvailable = date.isAfter(DateTime.now());
    }
  }

  @override
  void initState() {
    super.initState();
    getJobData();
  }

  Widget divideWidget() {
    return Column(
      children: const [
        SizedBox(height: 10,),
        Divider(
          thickness: 1,
          color: Colors.grey,
        ),
        SizedBox(height: 10,),
      ],
    );
  }

  applyForJob(){
    final Uri  params = Uri(
      scheme: 'mailto',
      path: emailCompany,
      query: 'subject= Applying for $jobTitle &body=Hello Please attach Resume CV.',
    );
    final url = params.toString();
    launchUrlString(url);
    addNewApplicant();
  }

  void addNewApplicant() async {
    var docRef = FirebaseFirestore.instance
        .collection('jobs')
        .doc(widget.jobID);
    docRef.update({
      'applicants': applicants + 1,
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepOrange.shade300, Colors.blueAccent],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: const [0.2, 0.9],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepOrange.shade300, Colors.blueAccent],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: const [0.2, 0.9],
              ),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close, size: 40, color: Colors.white,),
            onPressed: (){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => JobScreen()));
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Card(
                  color: Colors.black54,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            jobTitle == null
                                ?
                                ''
                                :
                                jobTitle!,
                            maxLines: 3,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 3,
                                  color: Colors.grey,
                                ),
                                shape: BoxShape.rectangle,
                                image: DecorationImage(
                                  image: NetworkImage(
                                    userImageUrl == null
                                        ?
                                        'https://static.vecteezy.com/system/resources/thumbnails/005/545/335/small/user-sign-icon-person-symbol-human-avatar-isolated-on-white-backogrund-vector.jpg'
                                        :
                                        userImageUrl!,
                                  ),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0,),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    authorName == null
                                        ?
                                        ''
                                        :
                                        authorName!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 5,),
                                  Text(
                                    locationCompany!,
                                    style:  const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        divideWidget(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              applicants.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(width: 6,),
                            const Text(
                              'Applicants',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(width: 10,),
                            const Icon(
                              Icons.how_to_reg_sharp,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                        FirebaseAuth.instance.currentUser!.uid != widget.uploadedBy
                        ?
                        Container()
                            :
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            divideWidget(),
                            const Text(
                              'Recruitment',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  onPressed: (){
                                    User? user = _auth.currentUser;
                                    final _uid = user!.uid;
                                    if(_uid == widget.uploadedBy){
                                      try{
                                        FirebaseFirestore.instance
                                            .collection('jobs')
                                            .doc(widget.jobID)
                                            .update({'recruitment':true});
                                      } catch (error) {
                                        GlobalMethod.showErrorDialog(
                                            error: 'Action cannot be performed',
                                            ctx: context,
                                        );
                                      }
                                    }
                                    else {
                                      GlobalMethod.showErrorDialog(
                                          error: 'You cannot perform this action',
                                          ctx: context,
                                      );
                                    }
                                    getJobData();
                                  },
                                  child: const Text(
                                    'ON',
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                                Opacity(
                                    opacity: recruitment == true ? 1 : 0,
                                  child: const Icon(
                                    Icons.check_box,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(width: 40,),
                                TextButton(
                                  onPressed: (){
                                    User? user = _auth.currentUser;
                                    final _uid = user!.uid;
                                    if(_uid == widget.uploadedBy){
                                      try{
                                        FirebaseFirestore.instance
                                            .collection('jobs')
                                            .doc(widget.jobID)
                                            .update({'recruitment':false});
                                      } catch (error) {
                                        GlobalMethod.showErrorDialog(
                                          error: 'Action cannot be performed',
                                          ctx: context,
                                        );
                                      }
                                    }
                                    else {
                                      GlobalMethod.showErrorDialog(
                                        error: 'You cannot perform this action',
                                        ctx: context,
                                      );
                                    }
                                    getJobData();
                                  },
                                  child: const Text(
                                    'OFF',
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                                Opacity(
                                  opacity: recruitment == false ? 1 : 0,
                                  child: const Icon(
                                    Icons.check_box,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        divideWidget(),
                        const Text(
                          'Job Description',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10,),
                        Text(
                          jobDescription == null
                              ?
                              ''
                              :
                              jobDescription!,
                          textAlign: TextAlign.justify,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        divideWidget(),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Card(
                  color: Colors.black54,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10,),
                        Center(
                          child: Text(
                            isDeadlineAvailable
                                ?
                                'Actively Recruiting, send CV/Resume:'
                                :
                                'Deadline passed away.',
                            style: TextStyle(
                              color: isDeadlineAvailable
                                  ?
                                  Colors.green
                                  :
                                  Colors.red,
                              fontWeight: FontWeight.normal,
                              fontSize: 16,

                            ),
                          ),
                        ),
                        const SizedBox(height: 6,),
                        Center(
                          child: MaterialButton(
                            onPressed: (){
                              applyForJob();
                            },
                            color: Colors.blueAccent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Text(
                                'Easy Apply Now',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        divideWidget(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Uploaded on:',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              postedDate == null
                                  ?
                                  ''
                                  :
                                  postedDate!,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Deadline Date:',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              deadlineDate == null
                                  ?
                              ''
                                  :
                              deadlineDate!,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        divideWidget(),

                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Card(
                  color: Colors.black54,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(
                            milliseconds: 500,
                          ),
                          child: _isCommenting
                              ?
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    flex: 3,
                                    child: TextField(
                                      controller: _commentController,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      maxLength: 200,
                                      keyboardType: TextInputType.text,
                                      maxLines: 6,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Theme.of(context).scaffoldBackgroundColor,
                                        enabledBorder: const UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.white),
                                        ),
                                        focusedBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.pink),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          child: MaterialButton(
                                            onPressed: () async {
                                              if(_commentController.text.length < 7){
                                                GlobalMethod.showErrorDialog(
                                                  error: 'comment cannot be less than 7 characters.',
                                                  ctx: context,
                                                );
                                              }
                                              else {
                                                final _generatedId = Uuid().v4();
                                                await FirebaseFirestore.instance
                                                    .collection('jobs')
                                                    .doc(widget.jobID)
                                                    .update({
                                                      'jobComments':
                                                          FieldValue.arrayUnion([{
                                                            'userId': FirebaseAuth.instance.currentUser!.uid,
                                                            'commentId':_generatedId,
                                                            'name': name,
                                                            'userImageUrl': userImage,
                                                            'commentBody': _commentController.text,
                                                            'time': Timestamp.now(),

                                                          }]),
                                                });
                                                await Fluttertoast.showToast(
                                                  msg: 'Your Comment has been added.',
                                                  toastLength: Toast.LENGTH_LONG,
                                                  backgroundColor: Colors.grey,
                                                  fontSize: 18,
                                                );
                                                _commentController.clear();
                                              }
                                              setState((){
                                                showComment = true;
                                              });
                                            },
                                            color: Colors.blueAccent,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              'Post',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: (){
                                            setState((){
                                              _isCommenting = !_isCommenting;
                                              showComment = false;
                                            });
                                          },
                                          child: const Text('Cancel'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                              :
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: (){
                                      setState((){
                                        _isCommenting = !_isCommenting;
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.add_comment,
                                      color: Colors.blueAccent,
                                      size: 40,
                                    ),
                                  ),
                                  const SizedBox(width: 10,),
                                  IconButton(
                                    onPressed: (){
                                      setState((){
                                        showComment = true;
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.arrow_drop_down_circle,
                                      color: Colors.blueAccent,
                                      size: 40,
                                    ),
                                  ),
                                ],
                              ),
                        ),
                        showComment == false
                            ?
                            Container()
                            :
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection('jobs')
                                    .doc(widget.jobID)
                                    .get(),
                                builder: (context, snapshot)
                                {
                                  if(snapshot.connectionState == ConnectionState.waiting){
                                    return const Center(child: CircularProgressIndicator(),);
                                  } else {
                                    if(snapshot.data == null){
                                      const Center(child: Text('No comment for this job.'),);
                                    }
                                  }
                                  return ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index){
                                      return CommentWidget(
                                        commentId: snapshot.data!['jobComments'] [index] ['commentId'],
                                        commenterId: snapshot.data!['jobComments'] [index] ['userId'],
                                        commenterName: snapshot.data!['jobComments'] [index] ['name'],
                                        commentBody: snapshot.data!['jobComments'] [index] ['commentBody'],
                                        commenterImageUrl: snapshot.data!['jobComments'] [index] ['userImageUrl'],

                                      );
                                    },
                                    separatorBuilder: (context, index)
                                    {
                                      return const Divider(
                                        thickness: 1,
                                        color: Colors.grey,
                                      );
                                    },
                                    itemCount: snapshot.data!['jobComments'].length,
                                  );
                                },
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
