import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpScreen extends StatefulWidget {
  final String contact; // phone or email used during login/register

  const OtpScreen({super.key, required this.contact});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  List<TextEditingController> controllers =
      List.generate(6, (index) => TextEditingController());

  int counter = 30;
  bool canResend = false;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (counter == 0) {
        setState(() => canResend = true);
        return false;
      }
      setState(() => counter--);
      return true;
    });
  }

  void verifyOtp() {
    String code = controllers.map((c) => c.text).join("");

    if (code.length == 6) {
      // TODO: connect to backend later
      Navigator.pushReplacementNamed(context, "/dashboard");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter all 6 digits")),
      );
    }
  }

  Widget otpField(int index) {
    return Container(
      width: 50,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blueAccent, width: 1.4),
      ),
      child: TextField(
        controller: controllers[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly
        ],
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            FocusScope.of(context).nextFocus();
          }
        },
        decoration: const InputDecoration(border: InputBorder.none),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Verify Your Account",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "An OTP has been sent to\n${widget.contact}",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 35),

            // OTP Boxes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) => otpField(index)),
            ),

            const SizedBox(height: 40),

            // Verify button
            ElevatedButton(
              onPressed: verifyOtp,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
              ),
              child: const Text("Verify OTP"),
            ),

            const SizedBox(height: 20),

            // Countdown or resend
            canResend
                ? TextButton(
                    onPressed: () {
                      setState(() {
                        counter = 30;
                        canResend = false;
                      });
                      startTimer();
                    },
                    child: const Text("Resend OTP"),
                  )
                : Text(
                    "Resend OTP in 00:${counter.toString().padLeft(2, '0')}",
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  )
          ],
        ),
      ),
    );
  }
}
