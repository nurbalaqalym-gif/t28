import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    // Модельді бүкіл қосымшаға қолжетімді етеміз
    ChangeNotifierProvider(create: (_) => CartModel(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: ShopPage());
  }
}

class Product {
  const Product(this.name, this.price);
  final String name;
  final int price;
}

// Себеттің деректері мен әрекеттері бір жерде тұрады
class CartModel extends ChangeNotifier {
  final List<Product> _items = [];

  List<Product> get items => List.unmodifiable(_items);
  int get total => _items.fold(0, (sum, p) => sum + p.price);

  void add(Product product) {
    _items.add(product);
    notifyListeners(); // «өзгеріс болды» деп тыңдаушыларға хабарлау
  }

  void removeAt(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

const List<Product> kProducts = [
  Product('Алма', 800),
  Product('Банан', 1200),
  Product('Қауын', 1500),
  Product('Жүзім', 2000),
];

// 1-бет: дүкен
class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    // watch: модель өзгергенде бұл виджет қайта салынады
    final count = context.watch<CartModel>().items.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Дүкен'),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: count > 0,
              label: Text('$count'),
              child: const Icon(Icons.shopping_cart),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartPage()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          for (final product in kProducts)
            ListTile(
              title: Text(product.name),
              subtitle: Text('${product.price} ₸'),
              trailing: IconButton(
                icon: const Icon(Icons.add_shopping_cart),
                onPressed: () {
                  // read: тек әрекет шақырамыз, тыңдамаймыз (onPressed ішінде осылай)
                  context.read<CartModel>().add(product);
                },
              ),
            ),
        ],
      ),
    );
  }
}

// 2-бет: себет. Деректі алдыңғы беттен жіберудің қажеті жоқ.
class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Consumer: тек осы бөлік модель өзгергенде қайта салынады
    return Consumer<CartModel>(
      builder: (context, cart, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Себет'),
            actions: [
              if (cart.items.isNotEmpty)
                TextButton(onPressed: cart.clear, child: const Text('Тазалау')),
            ],
          ),
          body: cart.items.isEmpty
              ? const Center(child: Text('Себет бос'))
              : ListView.builder(
                  itemCount: cart.items.length,
                  itemBuilder: (context, i) {
                    final p = cart.items[i];
                    return ListTile(
                      title: Text(p.name),
                      subtitle: Text('${p.price} ₸'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => cart.removeAt(i),
                      ),
                    );
                  },
                ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Барлығы: ${cart.total} ₸',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
