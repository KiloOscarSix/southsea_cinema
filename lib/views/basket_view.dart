import 'package:flutter/material.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/database/cinema_db.dart';
import 'package:southsea_cinema/models/basket_item.dart';
import 'package:southsea_cinema/models/booking.dart';
import 'package:southsea_cinema/models/booking_item.dart';
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
  List<Booking> _bookings = [];
  bool _loadingBookings = true;
  String _bookingsError = '';

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    try {
      final List<Booking> bookings =
          await CinemaDatabase.instance.getAllBookings();
      if (!mounted) {
        return;
      }
      setState(() {
        _bookings = bookings;
        _bookingsError = '';
        _loadingBookings = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _bookingsError = 'Could not load bookings: $error';
        _loadingBookings = false;
      });
    }
  }

  void _removeItem(int index) {
    setState(() {
      _basket.removeItem(index);
    });
  }

  // Go back to the home page to change the order
  // TODO: Future update will instead allow updating ticket quantities directly in the basket page
  void _updateOrder() {
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }

  String _buildSummary(List<BasketItem> items) {
    final List<String> lines = [];
    for (final BasketItem item in items) {
      lines.add('${item.quantity} x ${item.movie.title}');
    }
    return lines.join(', ');
  }

  String _formatDate(DateTime now) {
    final String day = now.day.toString().padLeft(2, '0');
    final String month = now.month.toString().padLeft(2, '0');
    final String hour = now.hour.toString().padLeft(2, '0');
    final String minute = now.minute.toString().padLeft(2, '0');
    return '$day/$month/${now.year} $hour:$minute';
  }

  Future<void> _checkout() async {
    final int tickets = _basket.getTotalTickets();
    final String noun = tickets == 1 ? 'ticket' : 'tickets';
    final String summary = _buildSummary(_basket.getItems());
    final double total = _basket.getTotal();
    final String date = _formatDate(DateTime.now());

    try {
      final CinemaDatabase database = CinemaDatabase.instance;
      final int bookingNumber = await database.getNextBookingNumber();

      final List<BookingItem> bookingItems = [];
      for (final BasketItem item in _basket.getItems()) {
        bookingItems.add(BookingItem(
          movieId: item.movie.id,
          movieTitle: item.movie.title,
          screeningTime: item.movie.screeningTime,
          unitPrice: item.movie.price,
          quantity: item.quantity,
        ));
      }

      final Booking booking = Booking(
        bookingNumber: bookingNumber,
        summary: summary,
        total: total,
        date: date,
        items: bookingItems,
      );

      await database.insertBooking(booking);
      _basket.clear();
      if (!mounted) {
        return;
      }
      setState(() {
        _confirmationMessage =
            'Booking #$bookingNumber confirmed for $tickets $noun.';
      });
      await _loadBookings();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _confirmationMessage = 'Could not save your booking: $error';
      });
    }
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
          Text('Your tickets'.toUpperCase(),
              style: Theme.of(context).textTheme.titleLarge),
          for (int i = 0; i < items.length; i++)
            _BasketLine(item: items[i], onDelete: () => _removeItem(i)),
          const Divider(color: cinemaFontMuted),
          _TotalRow(label: 'Tickets', value: '${_basket.getTotalTickets()}'),
          _TotalRow(
            label: 'Total to pay',
            value: '£${_basket.getTotal().toStringAsFixed(2)}',
            isBold: true,
          ),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: cinemaSpacingMedium,
            runSpacing: cinemaSpacingSmall,
            children: [
              PrimaryButton(
                label: 'Update order'.toUpperCase(),
                onPressed: _updateOrder,
              ),
              PrimaryButton(
                label: 'Checkout'.toUpperCase(),
                onPressed: () {
                  _checkout();
                },
              ),
            ],
          ),
          if (_confirmationMessage.isNotEmpty)
            Text(
              _confirmationMessage,
              style: cinemaBodyStyle.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
        ],
      );
    }

    final Widget pastBookings;
    if (_loadingBookings) {
      pastBookings = const Center(child: CircularProgressIndicator());
    } else if (_bookingsError.isNotEmpty) {
      pastBookings = Text(_bookingsError, style: cinemaMutedStyle);
    } else if (_bookings.isEmpty) {
      pastBookings = const Center(
        child: Text('No bookings yet', style: cinemaMutedStyle),
      );
    } else {
      pastBookings = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: cinemaSpacingSmall,
        children: [
          for (final Booking booking in _bookings)
            _BookingCard(booking: booking),
        ],
      );
    }

    content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: cinemaSpacingMedium,
      children: [
        content,
        const Divider(color: cinemaFontMuted),
        Text('Past bookings'.toUpperCase(),
            style: Theme.of(context).textTheme.titleLarge),
        pastBookings,
      ],
    );

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
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius:
            const BorderRadius.all(Radius.circular(cinemaCornerRadius)),
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
            key: ValueKey('remove-${item.movie.id}'),
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: 'Remove',
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(cinemaSpacingSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius:
            const BorderRadius.all(Radius.circular(cinemaCornerRadius)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Booking #${booking.bookingNumber}',
                style: cinemaBodyStyle.copyWith(fontWeight: FontWeight.bold),
              ),
              Text('£${booking.total.toStringAsFixed(2)}',
                  style: cinemaBodyStyle),
            ],
          ),
          if (booking.items.isEmpty)
            Text(booking.summary, style: cinemaBodyStyle)
          else
            for (final BookingItem item in booking.items)
              Text(
                '${item.quantity} x ${item.movieTitle} at ${item.screeningTime} - £${item.unitPrice.toStringAsFixed(2)} each: £${item.lineTotal.toStringAsFixed(2)}',
                style: cinemaBodyStyle,
              ),
          Text(booking.date, style: cinemaMutedStyle),
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
