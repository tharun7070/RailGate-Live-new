import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Status indicator widget showing gate status with color coding
class StatusIndicator extends StatelessWidget {
  final GateStatus status;
  final bool showLabel;
  final double size;

  const StatusIndicator({
    super.key,
    required this.status,
    this.showLabel = true,
    this.size = 12.0,
  });

  Color _getStatusColor() {
    switch (status) {
      case GateStatus.open:
        return AppColors.statusOpen;
      case GateStatus.closed:
        return AppColors.statusClosed;
      case GateStatus.likelyToClose:
        return AppColors.statusLikelyToClose;
      case GateStatus.unknown:
        return AppColors.statusUnknown;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: _getStatusColor(),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _getStatusColor().withOpacity(0.4),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
        if (showLabel) ...[
          const SizedBox(width: 8),
          Text(
            status.displayName,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ],
    );
  }
}

/// Clean card widget for gate information
class GateInfoCard extends StatelessWidget {
  final RailwayGate gate;
  final VoidCallback? onTap;
  final VoidCallback? onReportStatus;

  const GateInfoCard({
    super.key,
    required this.gate,
    this.onTap,
    this.onReportStatus,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      gate.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  StatusIndicator(status: gate.status, showLabel: false),
                ],
              ),
              const SizedBox(height: 8),
              if (gate.description != null && gate.description!.isNotEmpty)
                Text(
                  gate.description!,
                  style: theme.textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatusIndicator(status: gate.status),
                  if (gate.status == GateStatus.closed && gate.estimatedWaitTime > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.statusClosed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                      ),
                      child: Text(
                        '~${gate.estimatedWaitTime} min wait',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.statusClosed,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onReportStatus,
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Report Status'),
                    style: TextButton.styleFrom(
                      foregroundColor: isDark 
                          ? AppColors.primarySkyBlueLight 
                          : AppColors.primarySkyBlueDark,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Route summary card
class RouteSummaryCard extends StatelessWidget {
  final Route route;
  final bool isAlternate;
  final VoidCallback? onSelect;

  const RouteSummaryCard({
    super.key,
    required this.route,
    this.isAlternate = false,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final hasClosedGates = route.gatesOnRoute.any((g) => g.status == GateStatus.closed);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isAlternate ? 'Alternate Route' : 'Recommended Route',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (hasClosedGates)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.statusClosed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            size: 14,
                            color: AppColors.statusClosed,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${route.gatesOnRoute.where((g) => g.status == GateStatus.closed).length} closed',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.statusClosed,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoColumn(
                    context,
                    icon: Icons.route,
                    label: 'Distance',
                    value: '${route.distanceKm.toStringAsFixed(1)} km',
                  ),
                  _buildInfoColumn(
                    context,
                    icon: Icons.access_time,
                    label: 'Duration',
                    value: '${route.durationMinutes} min',
                  ),
                  _buildInfoColumn(
                    context,
                    icon: Icons.railway_alert,
                    label: 'Gates',
                    value: '${route.gatesOnRoute.length}',
                  ),
                ],
              ),
              if (route.gatesOnRoute.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: route.gatesOnRoute.map((gate) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: gate.status == GateStatus.closed
                            ? AppColors.statusClosed.withOpacity(0.1)
                            : gate.status == GateStatus.likelyToClose
                                ? AppColors.statusLikelyToClose.withOpacity(0.1)
                                : AppColors.statusOpen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: gate.status == GateStatus.closed
                                  ? AppColors.statusClosed
                                  : gate.status == GateStatus.likelyToClose
                                      ? AppColors.statusLikelyToClose
                                      : AppColors.statusOpen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              gate.name,
                              style: const TextStyle(fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
          ),
        ),
      ],
    );
  }
}
