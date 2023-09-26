// ignore_for_file: avoid_web_libraries_in_flutter, must_be_immutable

import 'dart:html';
import 'dart:typed_data';
import 'package:api_document/firebase/database.dart';
import 'package:flutter/material.dart';
import 'package:api_document/firebase/storage.dart' as storage;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class Create extends StatefulWidget {
  const Create({super.key});

  @override
  State<Create> createState() => _CreateState();
}

class _CreateState extends State<Create> {
  TextEditingController idInputController = TextEditingController();
  TextEditingController titleInputController = TextEditingController();
  TextEditingController domainInputController = TextEditingController();
  String alertText = '';
  late Uint8List imageData;

  Map<String, dynamic> data = {
    'color': '4278190080',
  };

  void alert(String text) {
    setState(() {
      alertText = text;
    });
    Future.delayed(const Duration(seconds: 3)).then(
      (value) => {
        setState(() {
          alertText = '';
        })
      },
    );
  }

  @override
  void dispose() {
    idInputController.dispose();
    titleInputController.dispose();
    domainInputController.dispose();
    super.dispose();
  }

  void upload() {
    FileUploadInputElement input = FileUploadInputElement();
    input.accept = 'image/*';
    input.click();
    input.onChange.listen((e) async {
      final files = input.files;
      if (files != null && files.length == 1) {
        final file = files[0];
        final reader = FileReader();
        reader.readAsArrayBuffer(file);
        reader.onLoadEnd.listen((e) async {
          data['thumbnail'] = file;
          final uint8List = Uint8List.fromList(reader.result as List<int>);
          imageData = uint8List;
          setState(() {});
        });
      }
    });
  }

  void subit() async {
    if (idInputController.text.isEmpty) {
      alert('프로젝트의 ID를 입력해 주세요!');
    } else if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(idInputController.text)) {
      alert('프로젝트의 ID는 영어나 숫자 또는 -, _ 만 입력할 수 있습니다!');
    } else if (titleInputController.text.isEmpty) {
      alert('프로젝트의 제목을 입력해 주세요!');
    } else if (domainInputController.text.isEmpty) {
      alert('홈페이지의 도메인을 입력해 주세요!');
    } else if (!domainInputController.text.startsWith('http://') && !domainInputController.text.startsWith('https://')) {
      alert('http 또는 https 까지 포함한 도메인을 입력해 주세요!');
    } else if (data['thumbnail'] == null) {
      alert('프로젝트의 썸네일을 업로드해 주세요!');
    } else if ((await selectRealtime('projects/${idInputController.text}')).keys.toList().isNotEmpty) {
      alert('이미 존재하는 프로젝트입니다.');
    } else {
      if (data['color'] ==null) {
        data['color'] = '4278190080';
      }
      data['title'] = titleInputController.text;
      data['domain'] = domainInputController.text;
      data['thumbnail'] =
          await storage.uploadFile(data['thumbnail'], idInputController.text);
      data['created_date'] = DateTime.now().toUtc().toIso8601String();
      insertRealtime(
        'projects/${idInputController.text}',
        data,
      );
      alert('[success]프로젝트 추가 성공');
      idInputController.value = const TextEditingValue();
      titleInputController.value = const TextEditingValue();
      domainInputController.value = const TextEditingValue();
      data = {
        'color': '4278190080',
      };
    }
  }

  Widget columnInput(String title,
      {String? hint, TextEditingController? controller, String? type}) {
    return Container(
      height: type == 'image' && data['thumbnail'] != null ? 300 : 50,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(240, 240, 240, 1.0),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 50),
      margin: const EdgeInsets.only(bottom: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Flexible(
            flex: 7,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: type == 'image'
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(
                          child: ElevatedButton(
                            onPressed: upload,
                            style: ElevatedButton.styleFrom(
                              primary: Colors.white70,
                              onPrimary: Colors.black54,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    8), // 원하는 radius 값으로 설정
                              ),
                            ),
                            child: const Text('이미지 선택'),
                          ),
                        ),
                        if (data['thumbnail'] != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Container(
                              color: Color(int.parse(data['color'])),
                              width: 230,
                              height: 200,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  imageData,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                      ],
                    )
                  : type == 'color'
                      ? GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext ctx) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(8), // 원하는 반경 값 설정
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Stack(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(30),
                                          child: SizedBox(
                                            width: 300,
                                            height: 300,
                                            child: MaterialPicker(
                                              pickerColor: Color(
                                                  int.parse(data['color'])),
                                              onColorChanged: (Color color) {
                                                data['color'] =
                                                    color.value.toString();
                                                setState(() {});
                                              },
                                              portraitOnly: true,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: IconButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            icon: const Icon(Icons.close),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Color(int.parse(data['color'])),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        )
                      : TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            hintText: hint,
                            hintStyle: const TextStyle(fontSize: 15),
                          ),
                          onSubmitted: (text) {
                            subit();
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Flexible(
                flex: 2,
                child: Center(
                  child: AutoSizeText(
                    '프로젝트 생성',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Flexible(
                flex: 9,
                child: SizedBox(
                  height: double.infinity,
                  child: SingleChildScrollView(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          columnInput(
                            'ID',
                            hint: '프로젝트 id를 입력해주세요.',
                            controller: idInputController,
                          ),
                          columnInput(
                            '제목',
                            hint: '프로젝트 제목을 입력해주세요.',
                            controller: titleInputController,
                          ),
                          columnInput(
                            '도메인',
                            hint: '프로젝트의 도메인을 입력해주세요.',
                            controller: domainInputController,
                          ),
                          columnInput('테마색상', type: 'color'),
                          columnInput('이미지', type: 'image'),
                        ]),
                  ),
                ),
              ),
              Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.arrow_back_ios_new, size: 30),
                      color: Colors.grey,
                    ),
                    IconButton(
                      onPressed: subit,
                      icon: const Icon(Icons.add, size: 30),
                      color: Colors.grey,
                    ),
                  ].map((e) => Flexible(child: e)).toList(),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              height: alertText != '' ? 50 : 0,
              width: double.infinity,
              color: alertText.contains('[success]')
                  ? Colors.blue.withOpacity(0.6)
                  : Colors.red.withOpacity(0.6),
              child: Center(
                  child: Text(
                alertText.replaceFirst('[success]', ''),
                style: const TextStyle(color: Colors.white, fontSize: 14),
              )),
            ),
          )
        ],
      ),
    );
  }
}
