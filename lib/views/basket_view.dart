import 'package:flutter/material.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/models/basket_item.dart';
import 'package:southsea_cinema/repositories/basket_repository.dart';
import 'package:southsea_cinema/widgets/nav_drawer.dart';
import 'package:southsea_cinema/widgets/primary_button.dart';

class BasketView extends StatefulWidget {
  const BasketView({super.key});

  @override
  State<BasketView> createState() => _BasketViewState();
}

class _BasketViewState extends State<BasketView> {
  final BasketRepository _basket = BasketRepository.instance;
  String _confirmationMessage = '';

  void _removeItem(int index) {
    setState(() {
      _basket.removeItem(index);
    });
  }

  void _checkout() {
    final int tickets = _basket.getTotalTickets();
    final String noun = tickets == 1 ? 'ticket' : 'tickets';

    setState(() {
      _confirmationMessage = 'Your order for $tickets $noun has been received.';
      _basket.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<BasketItem> items = _basket.getItems();

    // Checkout empties the basket
    Widget content;
    if (items.isEmpty) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: cinemaSpacingMedium,
        children: [
          const _EmptyBasket(),
          if (_confirmationMessage.isNotEmpty)
            Text(
              _confirmationMessage,
              style: cinemaBodyStyle.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
        ],
      );
    } else {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: cinemaSpacingMedium,
        children: [
          Text('Your tickets'.toUpperCase(), style: cinemaTitleStyle),
          for (int i = 0; i < items.length; i++)
            _BasketLine(item: items[i], onDelete: () => _removeItem(i)),
          const Divider(color: cinemaFontMuted),
          _TotalRow(label: 'Tickets', value: '${_basket.getTotalTickets()}'),
          _TotalRow(
            label: 'Total to pay',
            value: '£${_basket.getTotal().toStringAsFixed(2)}',
            isBold: true,
          ),
          PrimaryButton(
            label: 'Checkout'.toUpperCase(),
            onPressed: _checkout,
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Basket'),
      ),
      drawer: const NavDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(cinemaSpacingMedium),
        child: content,
      ),
    );
  }
}

class _EmptyBasket extends StatelessWidget {
  const _EmptyBasket();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Your basket is empty', style: cinemaMutedStyle),
    );
  }
}

class _BasketLine extends StatelessWidget {
  const _BasketLine({required this.item, required this.onDelete});

  final BasketItem item;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(cinemaSpacingSmall),
      decoration: const BoxDecoration(
        color: cinemaSurface,
        borderRadius: BorderRadius.all(Radius.circular(cinemaCornerRadius)),
      ),
      child: Row(
        spacing: cinemaSpacingSmall,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${item.quantity} x ${item.movie.title}',
                    style: cinemaBodyStyle),
                Text(item.movie.screeningTime, style: cinemaMutedStyle),
              ],
            ),
          ),
          Text('£${item.lineTotal.toStringAsFixed(2)}', style: cinemaBodyStyle),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: 'Remove',
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  final String label;
  final String value;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final TextStyle style = isBold
        ? cinemaBodyStyle.copyWith(fontWeight: FontWeight.bold)
        : cinemaBodyStyle;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
  }
}
