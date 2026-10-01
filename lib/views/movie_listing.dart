import 'package:flutter/material.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/widgets/nav_drawer.dart';

const String _filmTitle = 'Dracula';
const String _filmYear = '1931';
const String _filmRating = 'PG';
const String _filmDescription =
    "The dashing, mysterious Count Dracula (Bela Lugosi) travels to London and takes up residence in an old castle. Soon he begins to wreak havoc, sucking the blood of young women and turning them into vampires. Van Helsing is enlisted to put a stop to the count's never-ending bloodlust.";

class MovieListing extends StatelessWidget {
  const MovieListing({super.key});

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
      body: const Padding(
        padding: EdgeInsets.all(cinemaSpacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: cinemaSpacingMedium,
          children: [_FilmDetailsCard()],
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
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      spacing: cinemaSpacingSmall,
      children: [
        Text('$_filmTitle ($_filmYear)', style: cinemaTitleStyle),
        Text('($_filmRating)', style: cinemaBodyStyle),
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
