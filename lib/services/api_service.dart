import 'dart:convert';
import 'dart:io';
import 'package:bee2bee/models/cart_item_model.dart';
import 'package:bee2bee/models/order_item_model.dart';
import 'package:bee2bee/models/order_model.dart';
import 'package:bee2bee/models/place_model.dart';
import 'package:bee2bee/models/product_model.dart';
import 'package:bee2bee/models/user_model.dart';
import 'package:bee2bee/services/user_data_storage_service.dart';
import 'package:bee2bee/widgets/basic.dart';
import 'package:dio/dio.dart';
// import 'package:http/http.dart' as http;

class ApiService {
  final Dio _dio = Dio();
  // final String baseUrl = "http://192.168.1.23:5000";
  final String userBaseUrl = "http://192.168.1.44:5000/users";
  final String productBaseUrl = "http://192.168.1.44:5000/products";
  final String orderBaseUrl = "http://192.168.1.44:5000/orders";

  Future<bool?> checkUser(String primary) async {
    Map<String, String> data = {"primary": primary};
    try {
      Response<Map<String, dynamic>> response =
          await _dio.post(userBaseUrl + "/check-user", data: data);
      print(response);
      if (response.statusCode == 200) {
        // if (!response.data!["result"]) {
        return response.data!['result'];
        // }
        //else {
        //   // toastMessage(response.data!["message"]);
        //   return true;
        // }
      }
    } on DioError catch (e) {
      print("dio error occured: ${e.response!.statusCode}");
      if (e.error is SocketException) {
        internetToastMessage();
      } else if (e.response!.statusCode == 500) {
        print(e.response);
        toastMessage("Something went wrong! Try again");
      }
    } catch (e) {
      print("Exception Occured : $e");
      toastMessage("Something went wrong! Try again");
    }
    return null;
  }

  Future<String> sendOtp(String primary, String primaryType) async {
    Map<String, String> data = {"primary": primary, "primaryType": primaryType};
    try {
      Response<Map<String, dynamic>> response =
          await _dio.post(userBaseUrl + "/otp", data: data);
      print(response.data);
      if (response.data!["status"] == "success") {
        return response.data!["otp"];
      } else {
        toastMessage(response.data!["message"]);
      }
    } on DioError catch (e) {
      print("dio error occured: ${e.response}");
      if (e.error is SocketException) {
        internetToastMessage();
      }
      toastMessage("Something went wrong! Try again");
    } catch (e) {
      print(e);
      toastMessage("Something went wrong! Try again");
    }
    return "";
  }

  Future<bool> register(UserModel userModel) async {
    try {
      Response<Map<String, dynamic>> response =
          await _dio.post(userBaseUrl + "/user", data: userModel.toJson());
      print(response);

      await UserDataStorageService().setToken(response.data!["authToken"]);
      return true;
    } on DioError catch (e) {
      print("dio error occured: ${e.response}");
      if (e.error is SocketException) {
        internetToastMessage();
      } else {
        toastMessage("Something went wrong! Try again");
      }
    } catch (e) {
      print("Exception Occured : $e");
      toastMessage("Something went wrong! Try again");
    }
    return false;
  }

  Future<bool> login(Map<String, String> data) async {
    // String? token = await UserDataStorageService().getToken();
    // _dio.options.headers["Authorization"] = token!;

    try {
      Response<Map<String, dynamic>> response =
          await _dio.post(userBaseUrl + "/login", data: data);
      print(response);
      await UserDataStorageService().setToken(response.data!["authToken"]);
      return true;
    } on DioError catch (e) {
      print("dio error occured: ${e.response}");
      if (e.error is SocketException) {
        // internetToastMessage();
      } else {
        // toastMessage("Something went wrong! Try again");
      }
    } catch (e) {
      print("Exception Occured : $e");
      // toastMessage("Something went wrong! Try again");
    }
    return false;
  }

  Future<bool> logout() async {
    await UserDataStorageService().deleteToken();
    return true;
  }

  Future<bool> updateProfile(UserModel userModel) async {
    String? token = await UserDataStorageService().getToken();
    _dio.options.headers["Authorization"] = token!;
    try {
      Response<Map<String, dynamic>> response =
          await _dio.put(userBaseUrl + "/user", data: userModel.toJson());
      print(response);
      return true;
    } on DioError catch (e) {
      print("dio error occured: ${e.response}");
      if (e.error is SocketException) {
        internetToastMessage();
      } else {
        toastMessage("Something went wrong! Try again");
      }
    } catch (e) {
      print("Exception Occured : $e");
      toastMessage("Something went wrong! Try again");
    }
    return false;
  }

  Future<String> uploadProfilePhoto(File pic) async {
    String? token = await UserDataStorageService().getToken();
    try {
      _dio.options.headers["Authorization"] = token!;
      FormData formData = FormData.fromMap({
        "profilePic": await MultipartFile.fromFile(pic.path),
      });
      Response<Map<String, dynamic>> response = await _dio
          .post(userBaseUrl + "/upload-profile-picture", data: formData);
      print(response);
      return response.data!["result"];
    } on DioError catch (e) {
      print("dio error occured: ${e.response}");
      if (e.error is SocketException) {
        // internetToastMessage();
      } else {
        // toastMessage("Something went wrong! Try again");
      }
    } catch (e) {
      print("Exception Occured : $e");
      // toastMessage("Something went wrong! Try again");
    }
    return "";
  }

  Future<UserModel?> getCurrentUser() async {
    String? token = await UserDataStorageService().getToken();
    _dio.options.headers["Authorization"] = token!;
    try {
      Response<Map<String, dynamic>> response =
          await _dio.get(userBaseUrl + "/user");
      print(response);
      UserModel user = UserModel.fromJson(response.data!["result"]);
      return user;
    } on DioError catch (e) {
      print("dio error occured: ${e.response}");
      if (e.error is SocketException) {
        // internetToastMessage();
      } else {
        // toastMessage("Something went wrong! Try again");
      }
    } catch (e) {
      print("Exception Occured : $e");
      // toastMessage("Something went wrong! Try again");
    }
    return null;
  }

  Future<bool> addAddress(DeliveryAddress address) async {
    String? token = await UserDataStorageService().getToken();
    _dio.options.headers["Authorization"] = token!;
    try {
      Response<Map<String, dynamic>> response =
          await _dio.post(userBaseUrl + "/address", data: address.toJson());
      print(response);
      return true;
    } on DioError catch (e) {
      print("dio error occured: ${e.response}");
      if (e.error is SocketException) {
        // internetToastMessage();
      } else {
        // toastMessage("Something went wrong! Try again");
      }
    } catch (e) {
      print("Exception Occured : $e");
      // toastMessage("Something went wrong! Try again");
    }
    return false;
  }

  Future<bool> deleteAddress(DeliveryAddress address) async {
    String? token = await UserDataStorageService().getToken();
    _dio.options.headers["Authorization"] = token!;
    try {
      Response<Map<String, dynamic>> response =
          await _dio.delete(userBaseUrl + "/address", data: address.toJson());
      print(response);
      return true;
    } on DioError catch (e) {
      print("dio error occured: ${e.response}");
      if (e.error is SocketException) {
      } else {}
    } catch (e) {
      print("Exception Occured : $e");
    }
    return false;
  }

  Future<List<DeliveryAddress>> getAllAddresses() async {
    String? token = await UserDataStorageService().getToken();
    _dio.options.headers["Authorization"] = token!;
    try {
      Response<Map<String, dynamic>> response =
          await _dio.get(userBaseUrl + "/address");
      print(response);
      List<DeliveryAddress> addresses =
          deliveryAddressessFromJson(response.data!["result"]);
      return addresses;
    } on DioError catch (e) {
      print("dio error occured: ${e.response}");
      if (e.error is SocketException) {
        // internetToastMessage();
      } else {
        // toastMessage("Something went wrong! Try again");
      }
    } catch (e) {
      print("Exception Occured : $e");
      // toastMessage("Something went wrong! Try again");
    }
    return [];
  }

  Future<List<OrderCombinedModel>> getAllOrders() async {
    String? token = await UserDataStorageService().getToken();
    _dio.options.headers["Authorization"] = token!;
    try {
      Response<Map<String, dynamic>> response =
          await _dio.get(userBaseUrl + "/orders");
      print(response.data!["result"][0]["product"]);
      List<OrderCombinedModel> orders =
          orderItemsFromJson(response.data!["result"]);
      return orders;
    } on DioError catch (e) {
      print("dio error occured: ${e.response}");
      if (e.error is SocketException) {
        internetToastMessage();
      } else {
        // toastMessage("Something went wrong! Try again");
      }
    } catch (e) {
      print("Exception Occured : $e");
      // toastMessage("Something went wrong! Try again");
    }
    return [];
  }

  Future<bool> setDefaultAddress(DeliveryAddress address) async {
    String? token = await UserDataStorageService().getToken();
    _dio.options.headers["Authorization"] = token!;
    try {
      Response<Map<String, dynamic>> response = await _dio
          .post(userBaseUrl + "/set-default-address", data: address.toJson());
      print(response);
      return true;
    } on DioError catch (e) {
      print("dio error occured: ${e.response}");
      if (e.error is SocketException) {
        internetToastMessage();
      } else {
        toastMessage("Something went wrong! Try again");
      }
    } catch (e) {
      print("Exception Occured : $e");
      toastMessage("Something went wrong! Try again");
    }
    return false;
  }

  /// products related api calls

  Future<List<CategoryDetails>> getAllCategories() async {
    String? token = await UserDataStorageService().getToken();
    _dio.options.headers["Authorization"] = token!;
    try {
      Response<Map<String, dynamic>> response =
          await _dio.get(productBaseUrl + "/get-all-categories");
      print(response);
      List<CategoryDetails> categories =
          categoriesFromJson(response.data!["result"]);
      return categories;
    } on DioError catch (e) {
      print("dio error occured: ${e.response}");
      if (e.error is SocketException) {
        // internetToastMessage();
      } else {
        // toastMessage("Something went wrong! Try again");
      }
    } catch (e) {
      print("Exception Occured : $e");
      // toastMessage("Something went wrong! Try again");
    }
    return [];
  }

  Future<CategoryDetails?> getCategory() async {
    String? token = await UserDataStorageService().getToken();
    _dio.options.headers["Authorization"] = token!;
    try {
      Response<Map<String, dynamic>> response =
          await _dio.get(productBaseUrl + "/category");
      print(response);
      CategoryDetails category =
          CategoryDetails.fromJson(response.data!["result"]);
      return category;
    } on DioError catch (e) {
      print("dio error occured: ${e.response}");
      if (e.error is SocketException) {
        // internetToastMessage();
      } else {
        // toastMessage("Something went wrong! Try again");
      }
    } catch (e) {
      print("Exception Occured : $e");
      // toastMessage("Something went wrong! Try again");
    }
    return null;
  }

  Future<ProductModel?> getProduct(String key) async {
    String? token = await UserDataStorageService().getToken();
    _dio.options.headers["Authorization"] = token!;
    try {
      Response<Map<String, dynamic>> response =
          await _dio.get(productBaseUrl + "/product");
      print(response);
      ProductModel product = ProductModel.fromJson(response.data!["result"]);
      return product;
    } on DioError catch (e) {
      print("dio error occured: ${e.response}");
      if (e.error is SocketException) {
        // internetToastMessage();
      } else {
        // toastMessage("Something went wrong! Try again");
      }
    } catch (e) {
      print("Exception Occured : $e");
      // toastMessage("Something went wrong! Try again");
    }
    return null;
  }

  Future<List<ProductModel>> getAllProducts(
      String lastDocKey, int limit, String? category) async {
    String? token = await UserDataStorageService().getToken();
    _dio.options.headers["Authorization"] = token!;
    try {
      Response<Map<String, dynamic>> response = await _dio.get(
          productBaseUrl + "/get-all-products",
          queryParameters: {"category": category});
      print(response);
      List<ProductModel> products = productsFromJson(response.data!["result"]);
      return products;
    } on DioError catch (e) {
      print("dio error occured: ${e.response}");
      if (e.error is SocketException) {
        internetToastMessage();
      } else {
        // toastMessage("Something went wrong! Try again");
      }
    } catch (e) {
      print("Exception Occured : $e");
      // toastMessage("Something went wrong! Try again");
    }
    return [];
  }

  Future<List<ProductModel>> searchProduct(String searchTerm) async {
    String? token = await UserDataStorageService().getToken();
    _dio.options.headers["Authorization"] = token!;
    try {
      Response<Map<String, dynamic>> response = await _dio.get(
          productBaseUrl + "/search-product",
          queryParameters: {"searchTerm": searchTerm});
      print(response);
      List<ProductModel> products = productsFromJson(response.data!["result"]);
      return products;
    } on DioError catch (e) {
      print("dio error occured: ${e.response}");
      if (e.error is SocketException) {
        internetToastMessage();
      } else {
        // toastMessage("Something went wrong! Try again");
      }
    } catch (e) {
      print("Exception Occured : $e");
      // toastMessage("Something went wrong! Try again");
    }
    return [];
  }

  Future<bool> addToCart(CartItem cartItem) async {
    String? token = await UserDataStorageService().getToken();
    _dio.options.headers["Authorization"] = token!;
    try {
      Response<Map<String, dynamic>> response =
          await _dio.post(userBaseUrl + "/cart", data: cartItem.toJson());
      print("in try cart");
      print(response);

      return true;
    } on DioError catch (e) {
      print("dio error occured: ${e.response}");
      if (e.error is SocketException) {
        internetToastMessage();
      } else {
        // toastMessage("Something went wrong! Try again");
      }
    } catch (e) {
      print("Exception Occured at addtocart : $e");
      // toastMessage("Something went wrong! Try again");
    }
    return false;
  }

  Future<CartCombinedModel?> getCartItems() async {
    String? token = await UserDataStorageService().getToken();
    _dio.options.headers["Authorization"] = token!;
    try {
      Response<Map<String, dynamic>> response =
          await _dio.get(userBaseUrl + "/cart");
      print(response.data!['result']);

      CartCombinedModel prods =
          CartCombinedModel.fromJson(response.data!['result']);
      // print(prods[0].cartItem.quantity);
      // List<CartItem> cartitems =
      //     cartItemsFromJson(response.data!['result']['cartItemDetails']);
      // Map<String, dynamic> data = {"cartItems": cartitems, "products": prods};
      return prods;
    } on DioError catch (e) {
      print("dio error occured: ${e.response}");
      if (e.error is SocketException) {
        internetToastMessage();
      } else {
        toastMessage("Something went wrong! Try again");
      }
    } catch (e) {
      print("Exception Occured at addtocart : $e");
      // throw Error;
      toastMessage("Something went wrong! Try again");
    }
    return null;
  }

  Future<bool> removeFromCart(List<CartItem> items) async {
    String? token = await UserDataStorageService().getToken();
    _dio.options.headers["Authorization"] = token!;
    try {
      Response<Map<String, dynamic>> response =
          await _dio.delete(userBaseUrl + "/cart", data: {"cartItems": items});
      print("res ${response.data!['result']}");

      // CartItem it = CartItem.fromJson(response.data!['result']);
      return true;
    } on DioError catch (e) {
      // print("dio error occured: ${e.response}");
      if (e.error is SocketException) {
        // internetToastMessage();
      } else {
        // toastMessage("Something went wrong! Try again");
      }
    } catch (e) {
      // print("Exception Occured at addtocart : $e");
      // throw Error;
      // toastMessage("Something went wrong! Try again");
    }
    return false;
  }

  Future<bool> changeNoOfProdCart(Map<String, dynamic> item) async {
    String? token = await UserDataStorageService().getToken();
    _dio.options.headers["Authorization"] = token!;
    try {
      Response<Map<String, dynamic>> response =
          await _dio.put(userBaseUrl + "/cart", data: item);
      print("res ${response.data!['result']}");

      // CartItem it = CartItem.fromJson(response.data!['result']);
      return true;
    } on DioError catch (e) {
      // print("dio error occured: ${e.response}");
      if (e.error is SocketException) {
        // internetToastMessage();
      } else {
        // toastMessage("Something went wrong! Try again");
      }
    } catch (e) {
      // print("Exception Occured at addtocart : $e");
      // throw Error;
      // toastMessage("Something went wrong! Try again");
    }
    return false;
  }

  Future<bool> placeOrder(List<OrderModel> orders) async {
    String? token = await UserDataStorageService().getToken();
    _dio.options.headers["Authorization"] = token!;
    try {
      Response<Map<String, dynamic>> response =
          await _dio.post(orderBaseUrl + "/order", data: {"orders": orders});
      print("res ${response.data!['result']}");

      // CartItem it = CartItem.fromJson(response.data!['result']);
      return true;
    } on DioError catch (e) {
      print("dio error occured: ${e.response}");
      if (e.error is SocketException) {
        internetToastMessage();
      } else {
        toastMessage("Something went wrong! Try again");
      }
    } catch (e) {
      print("Exception Occured at addtocart : $e");
      toastMessage("Something went wrong! Try again");
    }
    return false;
  }

  Future<List<PlaceModel>> searchPlaceOnMap(String input) async {
    const mapApiKey = "AIzaSyC_2fIFDCfbf0xI7lTOEARgCQeH-yQV9h0";
    final requestUrl =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$mapApiKey';
    try {
      Response<Map<String, dynamic>> response = await _dio.post(requestUrl);
      // print(response.data!["predictions"][0]);
      List<PlaceModel> placesSuggestions =
          placesModelFromJson(response.data!["predictions"]);
      return placesSuggestions;
    } on DioError catch (e) {
      print("dio error occured: ${e.response}");
      if (e.error is SocketException) {
        internetToastMessage();
      } else {
        // toastMessage("Something went wrong! Try again");
      }
    } catch (e) {
      print("Exception Occured at addtocart : $e");
      // toastMessage("Something went wrong! Try again");
    }
    return [];
  }
}
