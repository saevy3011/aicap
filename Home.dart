import 'dart:convert';
import 'dart:io';

import 'package:ai_captioning/LiveCam.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<Home> {
  bool loading = true;
  File image;
  String resultText = "Identifying........";
  final pickerImage = ImagePicker();


  Future<Map <String, dynamic>> getResponse(File imageFile) async
  {
    final typeData = lookupMimeType(imageFile.path, headerBytes: [0xFF, 0xD8]).split("/");
    
    final imgUploadRequest = http.MultipartRequest("POST" , Uri.parse("http://max-image-caption-generator-test.2886795292-80-jago05.environments.katacoda.com/model/predict"));

    final file = await http.MultipartFile.fromPath("image", imageFile.path, contentType: MediaType(typeData[0], typeData[1]));

    imgUploadRequest.fields["ext"] = typeData[1];
    imgUploadRequest.files.add(file);

    try
    {
      final responseUpload = await imgUploadRequest.send();
      final response = await http.Response.fromStream(responseUpload);
      final Map<String, dynamic> responseData = json.decode(response.body);
      parseResponse(responseData);
      return responseData;
    }
    catch(e)
    {
      print(e);
      return null;
    }
  }

  parseResponse(var response)
  {
    String result = "";
    var predictions = response["predictions"];

    for(var pred in predictions)
      {
        var caption = pred["caption"];
        var probability = pred["probability"];
        result = result + caption + "\n\n";
      }

    setState(() {
      resultText = result;
    });
  }


  pickImageFromGallery() async
  {
    var imageFile = await pickerImage.getImage(source: ImageSource.gallery);
    if(imageFile !=null)
      {
        setState(() {
          image = File(imageFile.path);
          loading = false;
        });

         var res = getResponse(image);
      }
  }

  captureImage() async
  {
    var imageFile = await pickerImage.getImage(source: ImageSource.camera);
    if(imageFile !=null)
    {
      setState(() {
        image = File(imageFile.path);
        loading = false;
      });

      var res = getResponse(image);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/camera.jpg"),
            fit: BoxFit.cover,
          )
        ),
        child: Container(

          padding: EdgeInsets.all(30.0),

          child: Column(
            children: [
              Center(
                child: loading
                    //if true - display user interfacre.
                    ? Container(
                        margin: EdgeInsets.only(top: 180.0 ),
                        padding: EdgeInsets.only(bottom: 12.0),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(30.0),
                          boxShadow:
                          [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                            ),
                          ],
                        ),
                      child: Column(
                        children: [
                          SizedBox(height: 15.0,),
                          Container(
                            width: 250.0,
                            child: Image.asset("assets/ai.png"),
                          ),
                          SizedBox(height: 50.0,),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // live button
                              SizedBox.fromSize(
                                size: Size(80,80),
                                child: ClipOval(
                                  child: Material(
                                    color: Colors.orange,
                                    child: InkWell(
                                      splashColor: Colors.green,
                                      onTap: ()
                                      {
                                        print("clicked");
                                        Navigator.push(context, MaterialPageRoute(builder: (context)=> LiveCam()));
                                      },
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.camera_front, size: 40, ),
                                          Text("Live Camera", style: TextStyle(fontSize: 10.0) ,),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(width: 10,),

                              // Get from Gallery
                              SizedBox.fromSize(
                                size: Size(80,80),
                                child: ClipOval(
                                  child: Material(
                                    color: Colors.orange,
                                    child: InkWell(
                                      splashColor: Colors.green,
                                      onTap: ()
                                      {
                                        pickImageFromGallery();
                                        print("clicked");
                                      },
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.photo, size: 40, ),
                                          Text("Gallery", style: TextStyle(fontSize: 10.0) ,),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(width: 10,),

                              // Get From Camera
                              SizedBox.fromSize(
                                size: Size(80,80),
                                child: ClipOval(
                                  child: Material(
                                    color: Colors.orange,
                                    child: InkWell(
                                      splashColor: Colors.green,
                                      onTap: ()
                                      {
                                        captureImage();
                                        print("clicked");
                                      },
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.camera_alt, size: 40, ),
                                          Text("Camera", style: TextStyle(fontSize: 10.0) ,),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),



                            ],
                          )
                        ],
                      ),

                )
                    // if false - implement/ display results.
                    : Container(
                  color: Colors.black54,
                    margin: EdgeInsets.only(top: 70.0),
                      padding: EdgeInsets.only(top: 30.0),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            height: 200.0,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  child: IconButton(
                                    onPressed: ()
                                    {
                                      print("clicked");

                                    },
                                    icon: Icon(Icons.arrow_back_ios_outlined),
                                    color: Colors.white,

                                  ),
                                ),

                                Container(
                                  width: MediaQuery.of(context).size.width - 140,
                                  height: MediaQuery.of(context).size.height -140,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Image.file(image, fit: BoxFit.fill,),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 30.0,),
                          Container(
                            child: Text(
                              "______",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24.0,

                              ),
                            ),
                          ),
                          SizedBox(height: 30.0,),
                          Container(
                            child: Text(
                              resultText,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24.0,


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
      ),
    );
  }
}
