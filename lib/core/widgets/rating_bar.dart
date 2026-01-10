import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Star rating bar widget
class RatingBar extends StatelessWidget {
  final double rating;
  final int starCount;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool allowHalfRating;
  final ValueChanged<double>? onRatingChanged;

  const RatingBar({
    super.key,
    required this.rating,
    this.starCount = 5,
    this.size = 24,
    this.activeColor,
    this.inactiveColor,
    this.allowHalfRating = true,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(starCount, (index) {
        final starValue = index + 1;
        IconData icon;

        if (rating >= starValue) {
          icon = Icons.star_rounded;
        } else if (allowHalfRating && rating >= starValue - 0.5) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_outline_rounded;
        }

        return GestureDetector(
          onTap: onRatingChanged != null
              ? () => onRatingChanged!(starValue.toDouble())
              : null,
          child: Icon(
            icon,
            size: size,
            color: rating >= starValue - 0.5
                ? (activeColor ?? AppColors.secondary)
                : (inactiveColor ?? AppColors.textSecondary.withOpacity(0.3)),
          ),
        );
      }),
    );
  }
}

/// Interactive rating bar for user input
class InteractiveRatingBar extends StatefulWidget {
  final double initialRating;
  final ValueChanged<double> onRatingChanged;
  final double size;

  const InteractiveRatingBar({
    super.key,
    this.initialRating = 0,
    required this.onRatingChanged,
    this.size = 40,
  });

  @override
  State<InteractiveRatingBar> createState() => _InteractiveRatingBarState();
}

class _InteractiveRatingBarState extends State<InteractiveRatingBar> {
  late double _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        return GestureDetector(
          onTap: () {
            setState(() {
              _rating = starValue.toDouble();
            });
            widget.onRatingChanged(_rating);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              _rating >= starValue
                  ? Icons.star_rounded
                  : Icons.star_outline_rounded,
              size: widget.size,
              color: _rating >= starValue
                  ? AppColors.secondary
                  : AppColors.textSecondary.withOpacity(0.3),
            ),
          ),
        );
      }),
    );
  }
}
