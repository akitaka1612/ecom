import 'package:bee2bee/bloc/products_bloc.dart';
import 'package:bee2bee/constants/route_animation.dart';
import 'package:bee2bee/models/product_model.dart';
import 'package:bee2bee/screens/products.dart';
import 'package:bee2bee/services/api_service.dart';
import 'package:bee2bee/widgets/basic.dart';
import 'package:bee2bee/widgets/build_photo.dart';
import 'package:bee2bee/widgets/error_builder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({Key? key}) : super(key: key);

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  late Future<List<CategoryDetails>> categories;

  Future<void> getCategories() async {
    categories = ApiService().getAllCategories();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getCategories();
    // print("prducts");
  }

  @override
  Widget build(BuildContext context) {
    print("prducts");
    Size size = MediaQuery.of(context).size;
    return FutureBuilder<List<CategoryDetails>>(
      future: categories,
      builder: (context, snapshots) {
        if (snapshots.connectionState == ConnectionState.waiting) {
          return loadingAnimation();
        } else if (snapshots.hasError) {
          return buildErrorWidget(context, () => getCategories());
        }
        if (snapshots.data!.isEmpty) {
          return Container(
            alignment: Alignment.center,
            child: Text("No Categories Found",
                style: Theme.of(context).textTheme.headline3),
          );
        }
        print(snapshots.data);
        return SizedBox(
          height: size.height,
          width: size.width,
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            itemCount: snapshots.data!.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (context, index) {
              CategoryDetails category = snapshots.data![index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder:(context)=> BlocProvider<ProductBloc>(
                        create: (context) => ProductBloc(),
                        child: ProductsScreen(
                          categoryName: category.categoryName,
                          categoryKey: category.key,
                        ),
                      ),
                    ),
                  );
                },
                child: Card(
                    elevation: 5,
                    shadowColor: Color(0xffFFA500).withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          buildPhoto(
                              category.categoryPicture, size.height * 0.2),
                          SizedBox(height: 10),
                          Text(
                            category.categoryName,
                            style: Theme.of(context).textTheme.headline2,
                          ),
                        ],
                      ),
                    )),
              );
            },
          ),
        );
      },
    );
  }
}
