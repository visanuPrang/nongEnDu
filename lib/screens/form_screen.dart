import 'package:flutter/material.dart';

class FormScreen extends StatelessWidget {
  FormScreen({super.key});

  final emailController = TextEditingController();
  final nameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แบบฟอร์มบันทึกข้อมูล'),
      ),
      body: Form(
          child: Column(
        children: [
          TextFormField(
            controller: emailController,
            decoration: const InputDecoration(labelText: 'ชื่อรายการ'),
          ),
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'จำนวนเงิน'),
          ),
          TextButton(
            child: const Text('เพิ่มข้อมูล'),
            onPressed: () {
              var email = emailController.text;
              var name = nameController.text;
              debugPrint(email);
              debugPrint(name);
              debugPrint('4');
              debugPrint('5');
            },
          ),
        ],
      )),
    );
  }
}
