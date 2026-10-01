import 'package:flutter/material.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/widgets/nav_drawer.dart';

const String _filmTitle = 'Dracula';
const String _filmYear = '1931';
const String _filmRating = 'PG';
const String _filmDescription =
    "The dashing, mysterious Count Dracula (Bela Lugosi) travels to London and takes up residence in an old castle. Soon he begins to wreak havoc, sucking the blood of young women and turning them into vampires. Van Helsing is enlisted to put a stop to the count's never-ending bloodlust.";

const int _maxTicketsPerOrder = 5;

class MovieListing extends StatefulWidget {
  const MovieListing({super.key});

  @override
  State<MovieListing> createState() => _MovieListingState();
}

class _MovieListingState extends State<MovieListing> {
  int _quantity = 1;

  void _addToOrder() {
    final noun = _quantity == 1 ? 'ticket' : 'tickets';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$_quantity $noun for $_filmTitle added to your order'),
        ),
      );
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
      body: Padding(
        padding: const EdgeInsets.all(cinemaSpacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: cinemaSpacingMedium,
          children: [
            const _FilmDetailsCard(),
            DropdownMenu<int>(
              initialSelection: _quantity,
              label: const Text('Quantity'),
              textStyle: cinemaBodyStyle,
              dropdownMenuEntries: [
                for (var i = 1; i <= _maxTicketsPerOrder; i++)
                  DropdownMenuEntry<int>(value: i, label: '$i'),
              ],
              onSelected: (value) {
                if (value != null) {
                  setState(() {
                    _quantity = value;
                  });
                }
              },
            ),
            FilledButton(
              onPressed: _addToOrder,
              child: Text('Add to order'.toUpperCase()),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilmDetailsCard extends StatelessWidget {
  const _FilmDetailsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(cinemaSpacingMedium),
      decoration: const BoxDecoration(
        color: cinemaSurface,
        borderRadius: BorderRadius.all(Radius.circular(cinemaCornerRadius)),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: cinemaSpacingSmall,
        children: [_FilmHeader(), _FilmDescription()],
      ),
    );
  }
}

class _FilmHeader extends StatelessWidget {
  const _FilmHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      spacing: cinemaSpacingSmall,
      children: [
        Text('${_filmTitle.toUpperCase()} ($_filmYear)',
            style: cinemaTitleStyle),
        const Text('($_filmRating)', style: cinemaRatingStyle),
      ],
    );
  }
}

class _FilmDescription extends StatelessWidget {
  const _FilmDescription();

  @override
  Widget build(BuildContext context) {
    return const Text(_filmDescription, style: cinemaBodyStyle);
  }
}
