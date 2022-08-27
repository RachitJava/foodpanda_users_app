import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodpanda_users_app/assistantMethods/assistant_methods.dart';
import 'package:foodpanda_users_app/global/global.dart';
import 'package:foodpanda_users_app/mainScreens/payment_gateway.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'home_screen.dart';

class PaymentPage extends StatefulWidget {

  String? addressID;
  double? totalAmount;
  String? sellerUID;

  PaymentPage({this.sellerUID, this.totalAmount, this.addressID});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late   var _razorpay;
  var amountController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    super.initState();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Do something when payment succeeds
    print("Payment Done");
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
    print("Payment Fail");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet is selected
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: const CupertinoNavigationBar(
        middle: Text("CodeWithRachit"),
      ),
      body: Container(
        height: size.height,
        width: size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: TextField(
                controller: amountController,
                decoration:
                const InputDecoration(hintText: "Enter your Amount"),
              ),
            ),
            CupertinoButton(
                color: Colors.green,
                child: Text("Pay Amount"),
                onPressed: () {
                  ///Make payment
                  var options = {
                    'key': "rzp_test_UisgeycnsVbO2h",
                    // amount will be multiple of 100
                    'amount': (int.parse(amountController.text) * 100)
                        .toString(), //So its pay 500 //So its pay 500
                    'name': 'Code With Rachit',
                    'description': 'Demo',
                    'timeout': 300, // in seconds
                    'prefill': {
                      'contact': '7042082836',
                      'email': 'rachit.vishnoi16@gmail.com'
                    }
                  };
                  _razorpay.open(options);

                })
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _razorpay.clear();
    super.dispose();
  }

  String orderId = DateTime.now().millisecondsSinceEpoch.toString();

  addOnlineOrderDetails()
  {
    writeOrderDetailsForUser({
      'key': "rzp_test_UisgeycnsVbO2h",
      "addressID": widget.addressID,
      "totalAmount": widget.totalAmount,
      "orderBy": sharedPreferences!.getString("uid"),
      "productIDs": sharedPreferences!.getStringList("userCart"),
      "paymentDetails": "Online",
      "orderTime": orderId,
      "isSuccess": true,
      "sellerUID": widget.sellerUID,
      "riderUID": "",
      "status": "normal",
      "orderId": orderId,
    });

    writeOrderDetailsForSeller({
      "addressID": widget.addressID,
      "totalAmount": widget.totalAmount,
      "orderBy": sharedPreferences!.getString("uid"),
      "productIDs": sharedPreferences!.getStringList("userCart"),
      "paymentDetails": "Online",
      "orderTime": orderId,
      "isSuccess": true,
      "sellerUID": widget.sellerUID,
      "riderUID": "",
      "status": "normal",
      "orderId": orderId,
    }).whenComplete((){
      clearCartNow(context);
      setState(() {
        orderId="";
        Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
        Fluttertoast.showToast(msg: "Congratulations, Order has been placed successfully.");
      });
    });
  }
  Future writeOrderDetailsForUser(Map<String, dynamic> data) async
  {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(sharedPreferences!.getString("uid"))
        .collection("orders")
        .doc(orderId)
        .set(data);
  }

  Future writeOrderDetailsForSeller(Map<String, dynamic> data) async
  {
    await FirebaseFirestore.instance
        .collection("orders")
        .doc(orderId)
        .set(data);
  }
}