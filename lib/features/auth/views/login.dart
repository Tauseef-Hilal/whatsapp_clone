import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/auth/domain/auth_service.dart';

import 'package:whatsapp_clone/features/auth/controllers/login_controller.dart';
import 'package:whatsapp_clone/features/auth/views/verification.dart';
import 'package:whatsapp_clone/shared/utils/shared_pref.dart';
import 'package:whatsapp_clone/shared/models/phone.dart';
import 'package:whatsapp_clone/shared/utils/snackbars.dart';
import 'package:whatsapp_clone/shared/widgets/buttons.dart';
import 'package:whatsapp_clone/theme/colors.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  bool gotKeyboardHeight = false;

  @override
  void initState() {
    ref.read(loginControllerProvider.notifier).init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(verificationCodeProvider, (previous, next) {
      final formattedPhoneNumber =
          '+${ref.read(loginControllerProvider).phoneCode.trim()} ${ref.read(loginControllerProvider.notifier).phoneNumberController.text.trim()}';
      final phone = Phone(
        code: '+${ref.read(loginControllerProvider).phoneCode.trim()}',
        number: ref
            .read(loginControllerProvider.notifier)
            .phoneNumberController
            .text
            .replaceAll(' ', '')
            .replaceAll('-', '')
            .replaceAll('(', '')
            .replaceAll(')', ''),
        formattedNumber: formattedPhoneNumber,
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => VerificationPage(phone: phone),
        ),
        (route) => false,
      );

      showSnackBar(
        context: context,
        content: "OTP Sent!",
        type: SnacBarType.info,
      );
    });

    final screenWidth = MediaQuery.of(context).size.width;
    final selectedCountry = ref.watch(loginControllerProvider);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Enter your phone number'),
        centerTitle: true,
        backgroundColor: AppColors.backgroundColor,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 29.0),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(color: AppColors.textColor1),
                children: const [
                  TextSpan(
                    text: 'WhatsApp will need to verify your phone number. ',
                  ),
                  TextSpan(
                    text: 'What\'s my number?',
                    style: TextStyle(color: AppColors.blueColor),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => ref
                .read(loginControllerProvider.notifier)
                .showCountryPage(context),
            child: Container(
              padding: const EdgeInsets.only(top: 18.0),
              width: 0.60 * screenWidth,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.greenColor,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedCountry.displayNameNoCountryCode,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => ref
                        .read(loginControllerProvider.notifier)
                        .showCountryPage(context),
                    child: const Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.greenColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 0.75 * screenWidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 0.25 * (screenWidth * 0.60),
                  child: TextField(
                    onChanged: (value) {
                      ref
                          .read(loginControllerProvider.notifier)
                          .onPhoneCodeChanged(value);
                    },
                    style: Theme.of(context).textTheme.bodyText2,
                    keyboardType: TextInputType.phone,
                    textAlign: TextAlign.center,
                    cursorColor: AppColors.greenColor,
                    controller: ref
                        .read(loginControllerProvider.notifier)
                        .phoneCodeController,
                    decoration: const InputDecoration(
                      prefixText: '+ ',
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.greenColor,
                          width: 1,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.greenColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 0.05 * (screenWidth * 0.60),
                ),
                SizedBox(
                  width: 0.70 * (screenWidth * 0.60),
                  child: TextField(
                    onChanged: (value) async {
                      if (!gotKeyboardHeight) {
                        SharedPref.setDouble(
                          'keyboardHeight',
                          MediaQuery.of(context).viewInsets.bottom,
                        );

                        gotKeyboardHeight = true;
                      }
                    },
                    autofocus: true,
                    style: Theme.of(context).textTheme.bodyText2,
                    keyboardType: TextInputType.phone,
                    cursorColor: AppColors.greenColor,
                    controller: ref
                        .read(loginControllerProvider.notifier)
                        .phoneNumberController,
                    decoration: InputDecoration(
                      hintText: 'Phone number',
                      hintStyle: Theme.of(context).textTheme.bodySmall,
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.greenColor,
                          width: 1,
                        ),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.greenColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              'Carrier charges may apply.',
              style: Theme.of(context).textTheme.caption,
            ),
          ),
          const Expanded(
            child: SizedBox(
              height: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 130, vertical: 55),
            child: GreenElevatedButton(
              onPressed: () => ref
                  .read(loginControllerProvider.notifier)
                  .onNextBtnPressed(context),
              text: 'NEXT',
            ),
          ),
        ],
      ),
    );
  }
}
