// import 'package:flutter/material.dart';
// import 'package:flutter_app/models/food.dart';
// import 'package:flutter_app/models/cart_item.dart';
// import 'package:flutter_app/services/cart_service.dart';
// import 'package:provider/provider.dart';

// class FoodOrderPage extends StatefulWidget {
//   @override
//   _FoodOrderPageState createState() => _FoodOrderPageState();
// }

// class _FoodOrderPageState extends State<FoodOrderPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Color(0xFFFAFAFA),
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(
//             Icons.arrow_back_ios,
//             color: Color(0xFF3a3737),
//           ),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: Text(
//           "Your Cart",
//           style: TextStyle(
//             color: Color(0xFF3a3737),
//             fontWeight: FontWeight.w600,
//             fontSize: 18,
//           ),
//         ),
//         centerTitle: true,
//         actions: <Widget>[
//           Consumer<CartService>(
//             builder: (context, cart, child) {
//               return CartIconWithBadge(cartItemCount: cart.totalItems);
//             },
//           ),
//         ],
//       ),
//       body: Consumer<CartService>(
//         builder: (context, cart, child) {
//           if (cart.isLoading) {
//             return Center(
//               child: CircularProgressIndicator(
//                 color: Color(0xFFfb3132),
//               ),
//             );
//           }

//           if (cart.items.isEmpty) {
//             return _buildEmptyCart();
//           }

//           return _buildCartContent(cart);
//         },
//       ),
//     );
//   }

//   Widget _buildEmptyCart() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.shopping_cart_outlined,
//             color: Color(0xFFfae3e2),
//             size: 100,
//           ),
//           SizedBox(height: 20),
//           Text(
//             'Your cart is empty',
//             style: TextStyle(
//               fontSize: 22,
//               color: Color(0xFF3a3a3b),
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           SizedBox(height: 10),
//           Text(
//             'Add delicious food items to get started!',
//             style: TextStyle(
//               color: Color(0xFF6e6e71),
//               fontSize: 16,
//             ),
//           ),
//           SizedBox(height: 30),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context); // Go back to home
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Color(0xFFfb3132),
//               padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(25),
//               ),
//             ),
//             child: Text(
//               'Browse Foods',
//               style: TextStyle(fontSize: 16, color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCartContent(CartService cart) {
//     return SingleChildScrollView(
//       child: Container(
//         padding: EdgeInsets.all(15),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             Text(
//               "Your Food Cart (${cart.totalItems} items)",
//               style: TextStyle(
//                 fontSize: 20,
//                 color: Color(0xFF3a3a3b),
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             SizedBox(height: 15),

//             // Cart Items
//             ...cart.items.map((cartItem) {
//               return CartItemWidget(cartItem: cartItem);
//             }).toList(),

//             SizedBox(height: 20),

//             // Promo Code
//             PromoCodeWidget(),
//             SizedBox(height: 20),

//             // Order Summary
//             TotalCalculationWidget(cart: cart),
//             SizedBox(height: 20),

//             // Payment Method
//             Text(
//               "Payment Method",
//               style: TextStyle(
//                 fontSize: 20,
//                 color: Color(0xFF3a3a3b),
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             SizedBox(height: 10),
//             PaymentMethodWidget(),
//             SizedBox(height: 30),

//             // Checkout Button
//             _buildCheckoutButton(cart),
//             SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCheckoutButton(CartService cart) {
//     return Container(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: () {
//           _showCheckoutDialog(context, cart);
//         },
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Color(0xFFfb3132),
//           padding: EdgeInsets.symmetric(vertical: 18),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15),
//           ),
//           elevation: 5,
//         ),
//         child: Text(
//           'CHECKOUT - \$${cart.totalAmount.toStringAsFixed(2)}',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//       ),
//     );
//   }

//   void _showCheckoutDialog(BuildContext context, CartService cart) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(
//           'Confirm Order',
//           style: TextStyle(
//             color: Color(0xFF3a3a3b),
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Total Items: ${cart.totalItems}',
//               style: TextStyle(fontSize: 16),
//             ),
//             SizedBox(height: 5),
//             Text(
//               'Subtotal: \$${cart.subtotal.toStringAsFixed(2)}',
//               style: TextStyle(fontSize: 16),
//             ),
//             SizedBox(height: 5),
//             Text(
//               'Delivery Fee: \$${cart.deliveryFee.toStringAsFixed(2)}',
//               style: TextStyle(fontSize: 16),
//             ),
//             SizedBox(height: 10),
//             Divider(),
//             SizedBox(height: 5),
//             Text(
//               'Total: \$${cart.totalAmount.toStringAsFixed(2)}',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFFfb3132),
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'Cancel',
//               style: TextStyle(color: Colors.grey),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _showOrderSuccess(context);
//               cart.clearCart();
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Color(0xFFfb3132),
//             ),
//             child: Text('Confirm Order'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showOrderSuccess(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               Icons.check_circle,
//               color: Colors.green,
//               size: 60,
//             ),
//             SizedBox(height: 20),
//             Text(
//               'Order Placed Successfully!',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF3a3a3b),
//               ),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 10),
//             Text(
//               'Your food will be delivered in 30-45 minutes',
//               style: TextStyle(
//                 color: Color(0xFF6e6e71),
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//         actions: [
//           Center(
//             child: ElevatedButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 Navigator.pop(context); // Go back to home
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Color(0xFFfb3132),
//               ),
//               child: Text('Continue Shopping'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // CartItemWidget - Keep only ONE instance of this class!
// class CartItemWidget extends StatelessWidget {
//   final CartItem cartItem;

//   const CartItemWidget({
//     Key? key,
//     required this.cartItem,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final cart = Provider.of<CartService>(context);
//     final totalPrice = cartItem.totalPrice;

//     return Container(
//       margin: EdgeInsets.only(bottom: 15),
//       padding: EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//         boxShadow: [
//           BoxShadow(
//             color: Color(0xFFfae3e2).withOpacity(0.3),
//             blurRadius: 5,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           // Food Image
//           Container(
//             width: 80,
//             height: 80,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(8),
//               color: Color(0xFFfae3e2),
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(8),
//               child: _buildFoodImage(cartItem),
//             ),
//           ),
//           SizedBox(width: 15),

//           // Food Details
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: Text(
//                         cartItem.name,
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Color(0xFF3a3a3b),
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                         maxLines: 2,
//                       ),
//                     ),
//                     IconButton(
//                       icon: Icon(Icons.delete_outline, color: Colors.red),
//                       onPressed: () async {
//                         // Pass context for confirmation dialog
//                         await cart.removeFromCart(cartItem.id,
//                             context: context);
//                       },
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 5),
//                 Text(
//                   '\$${cartItem.price.toStringAsFixed(2)} each',
//                   style: TextStyle(
//                     color: Color(0xFF6e6e71),
//                     fontSize: 14,
//                   ),
//                 ),
//                 SizedBox(height: 10),

//                 // Quantity Controls
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       '\$${totalPrice.toStringAsFixed(2)}',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFFfb3132),
//                       ),
//                     ),
//                     Container(
//                       decoration: BoxDecoration(
//                         color: Color(0xFFf8f8f8),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Row(
//                         children: [
//                           IconButton(
//                             icon: Icon(Icons.remove, size: 18),
//                             onPressed: () {
//                               if (cartItem.quantity > 1) {
//                                 cart.updateQuantity(
//                                     cartItem.id, cartItem.quantity - 1);
//                               } else {
//                                 // Show confirmation when trying to remove last item
//                                 showDialog(
//                                   context: context,
//                                   builder: (context) => AlertDialog(
//                                     title: Text('Remove Item'),
//                                     content:
//                                         Text('Remove this item from cart?'),
//                                     actions: [
//                                       TextButton(
//                                         onPressed: () => Navigator.pop(context),
//                                         child: Text('Cancel'),
//                                       ),
//                                       ElevatedButton(
//                                         onPressed: () async {
//                                           Navigator.pop(context);
//                                           await cart.removeFromCart(cartItem.id,
//                                               context: context);
//                                         },
//                                         style: ElevatedButton.styleFrom(
//                                           backgroundColor: Color(0xFFfb3132),
//                                         ),
//                                         child: Text('Remove'),
//                                       ),
//                                     ],
//                                   ),
//                                 );
//                               }
//                             },
//                           ),
//                           Container(
//                             padding: EdgeInsets.symmetric(horizontal: 12),
//                             child: Text(
//                               '${cartItem.quantity}',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                           IconButton(
//                             icon: Icon(Icons.add, size: 18),
//                             onPressed: () {
//                               cart.updateQuantity(
//                                   cartItem.id, cartItem.quantity + 1);
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFoodImage(CartItem cartItem) {
//     if (cartItem.image.startsWith('http') ||
//         cartItem.image.startsWith('https')) {
//       return Image.network(
//         cartItem.image,
//         fit: BoxFit.cover,
//         errorBuilder: (context, error, stackTrace) {
//           return Icon(Icons.fastfood, color: Color(0xFFfb3132), size: 30);
//         },
//       );
//     } else {
//       try {
//         return Image.asset(
//           cartItem.image,
//           fit: BoxFit.cover,
//           errorBuilder: (context, error, stackTrace) {
//             return Icon(Icons.fastfood, color: Color(0xFFfb3132), size: 30);
//           },
//         );
//       } catch (e) {
//         return Icon(Icons.fastfood, color: Color(0xFFfb3132), size: 30);
//       }
//     }
//   }
// }

// // Cart Icon with Badge
// class CartIconWithBadge extends StatelessWidget {
//   final int cartItemCount;

//   const CartIconWithBadge({
//     Key? key,
//     required this.cartItemCount,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         IconButton(
//           icon: Icon(
//             Icons.shopping_cart,
//             color: Color(0xFF3a3737),
//           ),
//           onPressed: () {},
//         ),
//         if (cartItemCount > 0)
//           Positioned(
//             right: 8,
//             top: 8,
//             child: Container(
//               padding: EdgeInsets.all(2),
//               decoration: BoxDecoration(
//                 color: Color(0xFFfb3132),
//                 shape: BoxShape.circle,
//               ),
//               constraints: BoxConstraints(
//                 minWidth: 18,
//                 minHeight: 18,
//               ),
//               child: Center(
//                 child: Text(
//                   '$cartItemCount',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 10,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }

// // Promo Code Widget
// class PromoCodeWidget extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black12,
//             blurRadius: 3,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: TextField(
//         decoration: InputDecoration(
//           hintText: 'Enter promo code',
//           hintStyle: TextStyle(color: Colors.grey),
//           border: InputBorder.none,
//           contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
//           suffixIcon: Container(
//             margin: EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: Color(0xFFfb3132),
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: IconButton(
//               icon: Icon(Icons.discount, color: Colors.white),
//               onPressed: () {
//                 // Apply promo code
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // Total Calculation Widget
// class TotalCalculationWidget extends StatelessWidget {
//   final CartService cart;

//   const TotalCalculationWidget({
//     Key? key,
//     required this.cart,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black12,
//             blurRadius: 5,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           _buildRow('Subtotal', '\$${cart.subtotal.toStringAsFixed(2)}'),
//           SizedBox(height: 10),
//           _buildRow('Delivery Fee', '\$${cart.deliveryFee.toStringAsFixed(2)}'),
//           SizedBox(height: 10),
//           _buildRow(
//               'Tax (10%)', '\$${(cart.subtotal * 0.1).toStringAsFixed(2)}'),
//           SizedBox(height: 15),
//           Divider(thickness: 1),
//           SizedBox(height: 10),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Total',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF3a3a3b),
//                 ),
//               ),
//               Text(
//                 '\$${cart.totalAmount.toStringAsFixed(2)}',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFFfb3132),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRow(String label, String value) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             color: Color(0xFF6e6e71),
//             fontSize: 16,
//           ),
//         ),
//         Text(
//           value,
//           style: TextStyle(
//             color: Color(0xFF3a3a3b),
//             fontSize: 16,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     );
//   }
// }

// // Payment Method Widget
// class PaymentMethodWidget extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(15),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black12,
//             blurRadius: 3,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Image.asset(
//             'assets/images/menus/ic_credit_card.png',
//             width: 40,
//             height: 40,
//           ),
//           SizedBox(width: 15),
//           Expanded(
//             child: Text(
//               'Credit/Debit Card',
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Color(0xFF3a3a3b),
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           Radio(
//             value: 1,
//             groupValue: 1,
//             onChanged: (value) {},
//             activeColor: Color(0xFFfb3132),
//           ),
//         ],
//       ),
//     );
//   }
// }import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/food.dart';
import 'package:flutter_app/models/cart_item.dart';
import 'package:flutter_app/services/cart_service.dart';
import 'package:provider/provider.dart';

class FoodOrderPage extends StatefulWidget {
  @override
  _FoodOrderPageState createState() => _FoodOrderPageState();
}

class _FoodOrderPageState extends State<FoodOrderPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFAFAFA),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF3a3737),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Your Cart",
          style: TextStyle(
            color: Color(0xFF3a3737),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          Consumer<CartService>(
            builder: (context, cart, child) {
              return CartIconWithBadge(cartItemCount: cart.totalItems);
            },
          ),
        ],
      ),
      body: Consumer<CartService>(
        builder: (context, cart, child) {
          // Removed isLoading check - always show content
          if (cart.items.isEmpty) {
            return _buildEmptyCart();
          }
          return _buildCartContent(cart);
        },
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            color: Color(0xFFfae3e2),
            size: 100,
          ),
          SizedBox(height: 20),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 22,
              color: Color(0xFF3a3a3b),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Add delicious food items to get started!',
            style: TextStyle(
              color: Color(0xFF6e6e71),
              fontSize: 16,
            ),
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Go back to home
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFfb3132),
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              'Browse Foods',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(CartService cart) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Your Food Cart (${cart.totalItems} items)",
              style: TextStyle(
                fontSize: 20,
                color: Color(0xFF3a3a3b),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 15),
            // Cart Items
            ...cart.items.map((cartItem) {
              return CartItemWidget(cartItem: cartItem);
            }).toList(),
            SizedBox(height: 20),
            // Promo Code
            PromoCodeWidget(),
            SizedBox(height: 20),
            // Order Summary
            TotalCalculationWidget(cart: cart),
            SizedBox(height: 20),
            // Payment Method
            Text(
              "Payment Method",
              style: TextStyle(
                fontSize: 20,
                color: Color(0xFF3a3a3b),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10),
            PaymentMethodWidget(),
            SizedBox(height: 30),
            // Checkout Button
            _buildCheckoutButton(cart),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutButton(CartService cart) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _showCheckoutDialog(context, cart);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFfb3132),
          padding: EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
        ),
        child: Text(
          'CHECKOUT - \$${cart.totalAmount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _showCheckoutDialog(BuildContext context, CartService cart) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Confirm Order',
          style: TextStyle(
            color: Color(0xFF3a3a3b),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Items: ${cart.totalItems}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 5),
            Text(
              'Subtotal: \$${cart.subtotal.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 5),
            Text(
              'Delivery Fee: \$${cart.deliveryFee.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Divider(),
            SizedBox(height: 5),
            Text(
              'Total: \$${cart.totalAmount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFfb3132),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showOrderSuccess(context);
              cart.clearCart();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFfb3132),
            ),
            child: Text('Confirm Order'),
          ),
        ],
      ),
    );
  }

  void _showOrderSuccess(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 60,
            ),
            SizedBox(height: 20),
            Text(
              'Order Placed Successfully!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3a3a3b),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'Your food will be delivered in 30-45 minutes',
              style: TextStyle(
                color: Color(0xFF6e6e71),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Go back to home
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFfb3132),
              ),
              child: Text('Continue Shopping'),
            ),
          ),
        ],
      ),
    );
  }
}

// CartItemWidget - Keep only ONE instance of this class!
class CartItemWidget extends StatelessWidget {
  final CartItem cartItem;

  const CartItemWidget({
    Key? key,
    required this.cartItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartService>(context);
    final totalPrice = cartItem.totalPrice;

    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFfae3e2).withOpacity(0.3),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Food Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Color(0xFFfae3e2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildFoodImage(cartItem),
            ),
          ),
          SizedBox(width: 15),
          // Food Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        cartItem.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3a3a3b),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () async {
                        // Pass context for confirmation dialog
                        await cart.removeFromCart(cartItem.id,
                            context: context);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Text(
                  '\$${cartItem.price.toStringAsFixed(2)} each',
                  style: TextStyle(
                    color: Color(0xFF6e6e71),
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 10),
                // Quantity Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFfb3132),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFf8f8f8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove, size: 18),
                            onPressed: () {
                              if (cartItem.quantity > 1) {
                                cart.updateQuantity(
                                    cartItem.id, cartItem.quantity - 1);
                              } else {
                                // Show confirmation when trying to remove last item
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Remove Item'),
                                    content:
                                        Text('Remove this item from cart?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          await cart.removeFromCart(cartItem.id,
                                              context: context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFFfb3132),
                                        ),
                                        child: Text('Remove'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              '${cartItem.quantity}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add, size: 18),
                            onPressed: () {
                              cart.updateQuantity(
                                  cartItem.id, cartItem.quantity + 1);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodImage(CartItem cartItem) {
    if (cartItem.image.startsWith('http') ||
        cartItem.image.startsWith('https')) {
      return Image.network(
        cartItem.image,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.fastfood, color: Color(0xFFfb3132), size: 30);
        },
      );
    } else {
      try {
        return Image.asset(
          cartItem.image,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.fastfood, color: Color(0xFFfb3132), size: 30);
          },
        );
      } catch (e) {
        return Icon(Icons.fastfood, color: Color(0xFFfb3132), size: 30);
      }
    }
  }
}

// Cart Icon with Badge
class CartIconWithBadge extends StatelessWidget {
  final int cartItemCount;

  const CartIconWithBadge({
    Key? key,
    required this.cartItemCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: Icon(
            Icons.shopping_cart,
            color: Color(0xFF3a3737),
          ),
          onPressed: () {},
        ),
        if (cartItemCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Color(0xFFfb3132),
                shape: BoxShape.circle,
              ),
              constraints: BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Center(
                child: Text(
                  '$cartItemCount',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// Promo Code Widget
class PromoCodeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Enter promo code',
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          suffixIcon: Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFFfb3132),
              borderRadius: BorderRadius.circular(6),
            ),
            child: IconButton(
              icon: Icon(Icons.discount, color: Colors.white),
              onPressed: () {
                // Apply promo code
              },
            ),
          ),
        ),
      ),
    );
  }
}

// Total Calculation Widget
class TotalCalculationWidget extends StatelessWidget {
  final CartService cart;

  const TotalCalculationWidget({
    Key? key,
    required this.cart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildRow('Subtotal', '\$${cart.subtotal.toStringAsFixed(2)}'),
          SizedBox(height: 10),
          _buildRow('Delivery Fee', '\$${cart.deliveryFee.toStringAsFixed(2)}'),
          SizedBox(height: 10),
          _buildRow(
              'Tax (10%)', '\$${(cart.subtotal * 0.1).toStringAsFixed(2)}'),
          SizedBox(height: 15),
          Divider(thickness: 1),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3a3a3b),
                ),
              ),
              Text(
                '\$${cart.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFfb3132),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Color(0xFF6e6e71),
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Color(0xFF3a3a3b),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Payment Method Widget
class PaymentMethodWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/menus/ic_credit_card.png',
            width: 40,
            height: 40,
          ),
          SizedBox(width: 15),
          Expanded(
            child: Text(
              'Credit/Debit Card',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF3a3a3b),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Radio(
            value: 1,
            groupValue: 1,
            onChanged: (value) {},
            activeColor: Color(0xFFfb3132),
          ),
        ],
      ),
    );
  }
}
