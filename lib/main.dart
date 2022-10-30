import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:myshop/ui/orders/orders_screen.dart';
// import 'package:myshop/ui/products/edit_product_screen.dart';
// import 'package:myshop/ui/products/product_overview_screen.dart';
// import 'package:myshop/ui/products/products_manager.dart';
//import 'package:myshop/ui/products/user_products_screen.dart';
import 'ui/screens.dart';
Future<void> main() async {
  // (1) Load the .env file
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) :super(key: key);
  
  @override
  Widget build(BuildContext context) {
        return MultiProvider(
      providers: [
        // (2) Create the authmanage
        ChangeNotifierProvider(
          create: (context) => AuthManager() 
        ),
        ChangeNotifierProvider(
          create: (ctx) => ProductsManager(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => OrdersManager(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => CartManager(),
        ),
      ],
              // (3)) Consume the AuthManager  insatnce
            child: Consumer<AuthManager>(
              builder: (ctx, authManager, child){
                return MaterialApp(
                  title: 'My Shop',
                  debugShowCheckedModeBanner: false,
                  theme: ThemeData(
                    fontFamily: 'Lato',
                    colorScheme: ColorScheme.fromSwatch(
                      primarySwatch: Colors.purple,
                    ).copyWith(
                      secondary: Colors.deepOrange,
                    ),
                  ),
          home: authManager.isAuth 
                    ? const ProductsOverviewScreen() 
                    : FutureBuilder(
                      future: authManager.tryAutoLogin(),
                      builder: (context, snapshot) {
                        return snapshot.connectionState == ConnectionState.waiting 
                        ? const SplashScreen()
                        : const AuthScreen();
                },
                    ),
          routes: {
          CartScreen.routeName: (ctx) => const CartScreen(),
          OrdersScreen.routeName: (ctx) => const OrdersScreen(),
          UserProductsScreen.routeName: (ctx) => const UserProductsScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == ProductDetailScreen.routeName) {
            final productId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (ctx) {
                return ProductDetailScreen(
                  ctx.read<ProductsManager>().findById(productId),
                );
              },
            );
          }

          if (settings.name == EditProductScreen.routeName) {
            final productId = settings.arguments as String?;
            return MaterialPageRoute(
              builder: (ctx) {
                return EditProductScreen(
                  productId != null 
                  ? ctx.read<ProductsManager>().findById(productId)
                  :null,
                );
              },
            );
          }
          return null;
            },
          );
        }),
        );
  }
}

 
