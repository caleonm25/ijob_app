// ignore_for_file: prefer_if_null_operators

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:ijob_app/user_state.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../Widgets/bottom_nav_bar.dart';

class ProfileScreen extends StatefulWidget {
  final String userID;

  const ProfileScreen({required this.userID});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? name;
  String email = '';
  String phoneNumber = '';
  String imageUrl = '';
  String joinedAt = '';
  bool _isLoading = false;
  bool _isSameUser = false;

  void getUserData() async {
    try {
      _isLoading = true;
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userID)
          .get();
      if(userDoc == null){
        return;
      } else {
        setState((){
          name = userDoc.get('name');
          email = userDoc.get('email');
          phoneNumber = userDoc.get('phoneNumber');
          imageUrl = userDoc.get('userImage');
          Timestamp joinedAtTimeStamp = userDoc.get('createdAt');
          var joinedDate = joinedAtTimeStamp.toDate();
          joinedAt = '${joinedDate.year} - ${joinedDate.month} - ${joinedDate.day}';

        });
        User? user = _auth.currentUser;
        final _uid = user!.uid;
        setState((){
          _isSameUser = _uid == widget.userID;

        });
      }
    } catch (error) {} finally {
      _isLoading = false;
    }
  }

  @override
  void initState(){

    super.initState();
    getUserData();
  }

  Widget userInfo({required IconData icon, required String context})
  {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            context,
            style: const TextStyle(color: Colors.white54),
          ),
        ),
      ],
    );
  }

  Widget _contactBy({
  required Color color, required Function fct, required IconData icon
                    })
  {
    return CircleAvatar(
      backgroundColor: color,
      radius: 25,
      child: CircleAvatar(
        radius: 23,
        backgroundColor: Colors.white,
        child: IconButton(
          icon: Icon(
            icon,
            color: color,
          ),
          onPressed: (){
            fct();
          },
        ),
      ),
    );
  }

  void _openWhatsAppChat() async {
    var url = 'https://wa.me/$phoneNumber?text=HelloWorld';
    launchUrlString(url);
  }

  void _mailTo() async {
    final Uri params = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Write subject here, Please&body=Hello, please write details',
    );
    final url = params.toString();
    launchUrlString(url);
  }
  void _callPhoneNumber() async {
    var url = 'tel://$phoneNumber';
    launchUrlString(url);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
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
        bottomNavigationBar: BottomNavigationBarForApp(indexNum: 3,),
        backgroundColor: Colors.transparent,
        body: Center(
          child: _isLoading
              ?
          const Center(child: CircularProgressIndicator(),)
              :
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: Stack(
                    children: [
                      Card(
                        color: Colors.white10,
                        margin: const EdgeInsets.all(30),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 100,),
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  name == null
                                      ?
                                      'Name Here'
                                      :
                                      name!,
                                  style: const TextStyle(color: Colors.white, fontSize: 24.0),
                                ),
                              ),
                              const SizedBox(height: 15,),
                              const Divider(
                                thickness: 1,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 30,),
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Account info:',
                                  style: TextStyle(color: Colors.white, fontSize: 22.0,),
                                ),
                              ),
                              const SizedBox(height: 15,),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: userInfo(icon: Icons.email, context: email),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: userInfo(icon: Icons.phone, context: phoneNumber),
                              ),
                              const SizedBox(height: 25,),
                              const Divider(
                                thickness: 1,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 25,),
                              _isSameUser
                              ?
                              Container()
                                  :
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _contactBy(
                                        color: Colors.green,
                                        fct: () {
                                          _openWhatsAppChat();
                                        },
                                        icon: FontAwesome.whatsapp,
                                      ),
                                      _contactBy(
                                        color: Colors.red,
                                        fct: () {
                                          _mailTo();
                                        },
                                        icon: Icons.mail_outline,
                                      ),
                                      _contactBy(
                                        color: Colors.purple,
                                        fct: () {
                                          _callPhoneNumber();
                                        },
                                        icon: Icons.call,
                                      ),
                                    ],
                                  ),
                                  !_isSameUser
                                  ?
                                  Container()
                                  :
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 30),
                                      child: MaterialButton(
                                        onPressed: (){
                                          _auth.signOut();
                                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> UserState(),));
                                        },
                                        color: Colors.black,
                                        elevation: 8,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(13),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: const [
                                              Text(
                                                'Logout',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Signatra',
                                                  fontSize: 28,
                                                ),
                                              ),
                                              SizedBox(width: 8,),
                                              Icon(
                                                Icons.logout,
                                                color: Colors.white,
                                              ),
                                            ],
                                          ),
                                        ),

                                      ),
                                    ),
                                  ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: size.width * 0.26,
                            height: size.height * 0.16,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(
                                width: 8,
                                color: Theme.of(context).scaffoldBackgroundColor,
                              ),
                              image: DecorationImage(
                                image: NetworkImage(
                                  // ignore: unnecessary_null_comparison
                                  imageUrl == null
                                      ?
                                      'https://www.iconspng.com/image/140598/young-user-icon'
                                      :
                                      imageUrl,
                                ),
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
        ),
      ),
    );
  }
}
