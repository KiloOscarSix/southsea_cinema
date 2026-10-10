import 'package:flutter/material.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/models/movie.dart';
import 'package:southsea_cinema/widgets/nav_drawer.dart';

const int _maxTicketsPerOrder = 5;
const double _wideLayoutBreakpoint = 600;
const double _wideOrderPanelWidth = 240;
const double _posterWidth = 100;
const double _posterHeight = 150;

class MovieListing extends StatefulWidget {
  const MovieListing({super.key, required this.movie});

  final Movie movie;

  @override
  State<MovieListing> createState() => _MovieListingState();
}

class _MovieListingState extends State<MovieListing> {
  int _quantity = 1;
  String _orderMessage = '';

  void _addToOrder() {
    final noun = _quantity == 1 ? 'ticket' : 'tickets';
    setState(() {
      _orderMessage =
          '$_quantity $noun for ${widget.movie.title} added to your order';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(appTitle, style: cinemaHeaderStyle),
        backgroundColor: cinemaSurface,
        iconTheme: const IconThemeData(color: cinemaBrand),
        elevation: 0,
      ),
      drawer: const NavDrawer(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > _wideLayoutBreakpoint;
          final orderPanel = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: cinemaSpacingMedium,
            children: [
              DropdownMenu<int>(
                expandedInsets: EdgeInsets.zero,
                initialSelection: _quantity,
                label: const Text('Quantity'),
                dropdownMenuEntries: [
                  for (var i = 1; i <= _maxTicketsPerOrder; i++)
                    DropdownMenuEntry<int>(value: i, label: '$i'),
                ],
                onSelected: (value) {
                  if (value != null) {
                    setState(() => _quantity = value);
                  }
                },
              ),
              ElevatedButton(
                onPressed: _addToOrder,
                child: Text('Add to order'.toUpperCase()),
              ),
              Text(_orderMessage, style: cinemaBodyStyle),
            ],
          );

          return ListView(
            padding: const EdgeInsets.all(cinemaSpacingMedium),
            children: [
              isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: cinemaSpacingMedium,
                      children: [
                        Expanded(child: _FilmDetailsCard(movie: widget.movie)),
                        SizedBox(
                            width: _wideOrderPanelWidth, child: orderPanel),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: cinemaSpacingMedium,
                      children: [
                        _FilmDetailsCard(movie: widget.movie),
                        orderPanel
                      ],
                    ),
            ],
          );
        },
      ),
    );
  }
}

class _FilmDetailsCard extends StatelessWidget {
  const _FilmDetailsCard({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(cinemaSpacingMedium),
      decoration: const BoxDecoration(
        color: cinemaSurface,
        borderRadius: BorderRadius.all(Radius.circular(cinemaCornerRadius)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: cinemaSpacingSmall,
        children: [
          _FilmHeader(movie: movie),
          Image.asset(
            movie.imagePath,
            width: _posterWidth,
            height: _posterHeight,
            fit: BoxFit.cover,
          ),
          Text(movie.screeningTime, style: cinemaBodyStyle),
          Text(movie.formattedPrice, style: cinemaBodyStyle),
          _FilmDescription(movie: movie),
        ],
      ),
    );
  }
}

class _FilmHeader extends StatelessWidget {
  const _FilmHeader({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      spacing: cinemaSpacingSmall,
      children: [
        Expanded(
          child: Text('${movie.title.toUpperCase()} (${movie.year})',
              style: cinemaTitleStyle),
        ),
        Text('(${movie.ageRating})', style: cinemaRatingStyle),
      ],
    );
  }
}

class _FilmDescription extends StatelessWidget {
  const _FilmDescription({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return Text(movie.description, style: cinemaBodyStyle);
  }
}
