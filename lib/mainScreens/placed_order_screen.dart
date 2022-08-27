import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodpanda_users_app/assistantMethods/assistant_methods.dart';
import 'package:foodpanda_users_app/assistantMethods/total_amount.dart';
import 'package:foodpanda_users_app/global/global.dart';
import 'package:foodpanda_users_app/mainScreens/address_screen.dart';
import 'package:foodpanda_users_app/mainScreens/cart_screen.dart';
import 'package:foodpanda_users_app/mainScreens/payment_gateway.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'home_screen.dart';


class PlacedOrderScreen extends StatefulWidget
{
  String? addressID;
  double? totalAmount;
  String? sellerUID;
  String? email;

  PlacedOrderScreen({this.sellerUID, this.totalAmount, this.addressID, this.email});

  @override
  _PlacedOrderScreenState createState() => _PlacedOrderScreenState();
}



class _PlacedOrderScreenState extends State<PlacedOrderScreen>
{
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
    print("Payment Done");
    addOnlineOrderDetails();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
    print("Payment Fail");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet is selected
  }

  String orderId = DateTime.now().millisecondsSinceEpoch.toString();

  addOrderDetails()
  {
    writeOrderDetailsForUser({
      "addressID": widget.addressID,
      "totalAmount": widget.totalAmount,
      "orderBy": sharedPreferences!.getString("uid"),
      "productIDs": sharedPreferences!.getStringList("userCart"),
      "paymentDetails": "Cash on Delivery",
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
      "paymentDetails": "Cash on Delivery",
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

  @override
  Widget build(BuildContext context)
  {
    return Material(
      child: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.cyan,
                Colors.cyan,
              ],
              begin:  FractionalOffset(0.0, 0.0),
              end:  FractionalOffset(1.0, 0.0),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp,
            )
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Image.asset("images/delivery.jpg"),

            const SizedBox(height: 12,),


            ElevatedButton(
              child: const Text("Pay Online"),
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
              ),
              onPressed: ()
              async {
                // Navigator.push(context, MaterialPageRoute(builder: (c)=> PaymentPage()));
                var amount = widget.totalAmount;
                var options = {
                  'key': "rzp_test_UisgeycnsVbO2h",
                  // amount will be multiple of 100
                  'amount': ((widget.totalAmount)! * 100).round(), //So its pay 500 //So its pay 500
                  'name': FirebaseAuth.instance.currentUser?.displayName,
                  'description': 'Welcome!',
                  'timeout': 300, // in seconds
                  'prefill': {
                    'contact': '',
                    // 'email': await FirebaseAuth.instance.currentUser?.email
                    'email': ''
                  }
                };
                _razorpay.open(options);





              },

            ),
            ElevatedButton(
              child: const Text("Cash On Delivery"),
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
              ),
              onPressed: ()
              {
                addOrderDetails();
              },
            ),

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
}
