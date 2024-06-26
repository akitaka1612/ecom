import 'package:bee2bee/constants/constant_values.dart';
import 'package:bee2bee/constants/route_animation.dart';
import 'package:bee2bee/models/order_item_model.dart';
import 'package:bee2bee/models/order_model.dart';
import 'package:bee2bee/screens/order_track.dart';
import 'package:bee2bee/screens/product_details.dart';
import 'package:bee2bee/services/api_service.dart';
import 'package:bee2bee/widgets/basic.dart';
import 'package:bee2bee/widgets/build_photo.dart';
import 'package:bee2bee/widgets/error_builder.dart';
import 'package:flutter/material.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future<List<OrderCombinedModel>> orders;
  void getOrders() {
    orders = ApiService().getAllOrders();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getOrders();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: const Text("Your Orders"),
        ),
        body: FutureBuilder<List<OrderCombinedModel>>(
            future: orders,
            builder: (context, snapshots) {
              if (snapshots.connectionState == ConnectionState.waiting) {
                return loadingAnimation();
              } else if (snapshots.hasError) {
                return buildErrorWidget(context, () => getOrders());
              }
              if (snapshots.data!.isEmpty) {
                return Center(
                    child: Text(
                  "No Orders Found! Add One",
                  style: Theme.of(context).textTheme.headline3,
                ));
              }
              return ListView.builder(
                itemCount: snapshots.data!.length,
                itemBuilder: (context, index) {
                  OrderCombinedModel order = snapshots.data![index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          SlideLeftRoute(
                            widget: OrderTrackScreen(
                              orderCombinedModel: snapshots.data![index],
                            ),
                          ));
                    },
                    child: Container(
                      margin: EdgeInsets.all(8),
                      // height: size.height * 0.2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: Color(0xffF0E0D8),
                                  ),
                                  height: size.height * 0.17,
                                  width: size.width * 0.32,
                                  child: buildPhoto(
                                    order.productDetails.productPicture,
                                    size.height * 0.12,
                                    size.width * 0.3,
                                    BoxFit.contain,
                                  )),
                              // SizedBox(height: size.height * 0.02),
                            ],
                          ),
                          SizedBox(width: 10),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  "${order.productDetails.productName} (${order.orderDetails.productDetails.noOfItems} items)",
                                  style: Theme.of(context).textTheme.headline2),
                              SizedBox(height: 5),
                              Text(
                                  order.orderDetails.productDetails
                                          .variationQuantity
                                          .toString() +
                                      " KG",
                                  style: Theme.of(context).textTheme.headline4),
                              SizedBox(height: 5),
                              Text(
                                  rupeeSymbol +
                                      order.orderDetails.paidPrice.toString(),
                                  style: Theme.of(context).textTheme.headline1),
                              SizedBox(height: 5),
                              Text(
                               order.orderDetails.deliveryStages.length == 4?  "Delivered on ${order.orderDetails.deliveryStages[3].toString().split(' ')[0]}": "Delivery on ${ order.orderDetails.deliveryStages.last.add(Duration(days: 3)).toString().split(' ')[0] }",
                                  style: Theme.of(context).textTheme.bodyText1),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            }));
  }
}
