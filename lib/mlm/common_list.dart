// File: widgets/common_list_card.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class CommonListCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final String title;
  final String subtitle;
  final String status;
  final Color statusColor;
  final IconData icon;
  final List<InfoRow> infoRows;
  final bool showShadow;
  final Color backgroundColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const CommonListCard({
    Key? key,
    required this.data,
    required this.title,
    required this.subtitle,
    required this.status,
    this.statusColor = Colors.blueAccent,
    this.icon = UniconsLine.award,
    this.infoRows = const [],
    this.showShadow = true,
    this.backgroundColor = Colors.white,
    this.borderRadius = 24.0,
    this.padding = const EdgeInsets.all(18),
    this.margin = const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  }) : super(key: key);

  @override
  State<CommonListCard> createState() => _CommonListCardState();
}

class _CommonListCardState extends State<CommonListCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.985 : 1.0,
      duration: const Duration(milliseconds: 140),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: Container(
          margin: widget.margin,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: widget.statusColor.withOpacity(0.22),
                blurRadius: 18,
                spreadRadius: 0.5,
                offset: const Offset(0, 8),
              ),
            ],
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6), // Balanced blur
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.backgroundColor.withOpacity(0.95),
                      Colors.white.withOpacity(0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  border: Border.all(
                    color: widget.statusColor.withOpacity(0.18),
                    width: 1.1,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Floating status badge
                    Positioned(
                      top: 10,
                      right: 14,
                      child: _buildStatusBadge(),
                    ),

                    Padding(
                      padding: widget.padding,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // LEFT COLUMN (Icon Section)
                          _buildLeftColumn(),

                          // Vertical divider glow
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            width: 1.0,
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  widget.statusColor.withOpacity(0.28),
                                  widget.statusColor.withOpacity(0.03),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),

                          // RIGHT COLUMN (Details)
                          Expanded(child: _buildRightColumn(context)),
                        ],
                      ),
                    ),

                    // ✨ Elegant Bottom Center Fade Line
                    Positioned(
                      bottom: 10,
                      child: Container(
                        width: 120,
                        height: 3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.transparent,
                              widget.statusColor.withOpacity(0.5),
                              widget.statusColor.withOpacity(0.7),
                              widget.statusColor.withOpacity(0.5),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.statusColor.withOpacity(0.35),
                              blurRadius: 10,
                              spreadRadius: 0.2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Left Column: Glowing Icon Section
  Widget _buildLeftColumn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.88, end: 1.0),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      widget.statusColor.withOpacity(0.32),
                      widget.statusColor.withOpacity(0.08),
                    ],
                    focal: Alignment.center,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.statusColor.withOpacity(0.28),
                      blurRadius: 14,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(
                  widget.icon,
                  size: 30,
                  color: widget.statusColor,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Right Column: Title, Subtitle, and Info Grid (with left+right shown)
  Widget _buildRightColumn(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            widget.subtitle,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),

          // Info Grid — each InfoRow becomes a wide info card showing left and right pairs
          Wrap(
            runSpacing: 10,
            spacing: 12,
            children: widget.infoRows.map((row) {
              return _buildInfoBoxWithBoth(row);
            }).toList(),
          ),

          const SizedBox(height: 36), // space for badge and bottom line
        ],
      ),
    );
  }

  /// Each info box shows both left and right title/value pairs
  Widget _buildInfoBoxWithBoth(InfoRow row) {
    return Container(
      width: 160,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: widget.statusColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.statusColor.withOpacity(0.14),
          width: 0.9,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left pair (primary)
          Text(
            row.leftTitle,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[800],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            row.leftValue,
            style: const TextStyle(
              fontSize: 13.5,
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Divider between left and right pairs
          if ((row.rightTitle.isNotEmpty || row.rightValue.isNotEmpty)) ...[
            const SizedBox(height: 8),
            Container(height: 0.6, color: Colors.grey.withOpacity(0.12)),
            const SizedBox(height: 8),

            // Right pair (secondary)
            Text(
              row.rightTitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[800],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              row.rightValue,
              style: TextStyle(
                fontSize: 13.0,
                color: Colors.blueGrey[700],
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Floating Status Badge (top-right)
  Widget _buildStatusBadge() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.statusColor,
            widget.statusColor.withOpacity(0.75),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: widget.statusColor.withOpacity(0.36),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        widget.status.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// InfoRow used for data display (keeps left+right fields)
class InfoRow {
  final String leftTitle;
  final String leftValue;
  final String rightTitle;
  final String rightValue;

  InfoRow({
    required this.leftTitle,
    required this.leftValue,
    required this.rightTitle,
    required this.rightValue,
  });
}
