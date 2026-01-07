/// SilentVoice AI - History Screen
/// ================================
/// View past gesture detection history.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../services/database_service.dart';
import '../core/constants/gesture_labels.dart';
import '../models/gesture_history_model.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  List<GestureHistoryModel> _history = [];
  Map<String, int> _stats = {};
  bool _isLoading = true;
  String _filterGesture = 'All';
  DateTime? _filterDate;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);

    try {
      final history = await DatabaseService.instance.getGestureHistory(
        limit: 100,
        gesture: _filterGesture == 'All' ? null : _filterGesture,
        startDate: _filterDate,
      );
      final stats = await DatabaseService.instance.getGestureStats();

      setState(() {
        _history = history;
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detection History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _showClearHistoryDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
              ? _buildEmptyState(theme)
              : _buildHistoryContent(theme),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: theme.colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text('No detection history yet', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Start detecting gestures to see history here',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryContent(ThemeData theme) {
    return CustomScrollView(
      slivers: [
        // Stats Overview
        SliverToBoxAdapter(child: _buildStatsCard(theme)),

        // Filter chips
        SliverToBoxAdapter(child: _buildFilterSection(theme)),

        // History List
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final item = _history[index];
              return _buildHistoryItem(theme, item, index);
            }, childCount: _history.length),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(ThemeData theme) {
    final totalDetections = _stats.values.fold<int>(0, (a, b) => a + b);
    final uniqueGestures = _stats.length;
    final mostCommon = _stats.entries.isEmpty
        ? 'N/A'
        : _stats.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Statistics',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    theme,
                    totalDetections.toString(),
                    'Total',
                    Icons.gesture,
                  ),
                  _buildStatItem(
                    theme,
                    uniqueGestures.toString(),
                    'Unique',
                    Icons.fingerprint,
                  ),
                  _buildStatItem(
                    theme,
                    GestureLabels.getDisplayName(mostCommon),
                    'Most Common',
                    Icons.star,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    ThemeData theme,
    String value,
    String label,
    IconData icon,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filter:', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (_filterGesture != 'All')
                Chip(
                  label: Text(_filterGesture),
                  onDeleted: () {
                    setState(() => _filterGesture = 'All');
                    _loadHistory();
                  },
                ),
              if (_filterDate != null)
                Chip(
                  label: Text(DateFormat.yMMMd().format(_filterDate!)),
                  onDeleted: () {
                    setState(() => _filterDate = null);
                    _loadHistory();
                  },
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(
    ThemeData theme,
    GestureHistoryModel item,
    int index,
  ) {
    final timeFormat = DateFormat.jm();
    final dateFormat = DateFormat.yMMMd();

    // Check if this is a new day
    bool showDate = index == 0 ||
        !_isSameDay(_history[index - 1].timestamp, item.timestamp);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showDate)
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Text(
              _isToday(item.timestamp)
                  ? 'Today'
                  : _isYesterday(item.timestamp)
                      ? 'Yesterday'
                      : dateFormat.format(item.timestamp),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  item.gesture.length == 1
                      ? item.gesture
                      : item.gesture.substring(0, 2).toUpperCase(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
            title: Text(
              GestureLabels.getDisplayName(item.gesture),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: theme.textTheme.bodySmall?.color,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    timeFormat.format(item.timestamp),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.percent,
                  size: 14,
                  color: theme.textTheme.bodySmall?.color,
                ),
                const SizedBox(width: 4),
                Text(item.confidenceString),
              ],
            ),
            trailing: _buildConfidenceIndicator(theme, item.confidence),
            onTap: () => _showHistoryDetail(context, item),
          ),
        ),
      ],
    );
  }

  Widget _buildConfidenceIndicator(ThemeData theme, double confidence) {
    Color color;
    if (confidence >= 0.8) {
      color = Colors.green;
    } else if (confidence >= 0.6) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Container(
      width: 8,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return _isSameDay(date, now);
  }

  bool _isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return _isSameDay(date, yesterday);
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter History',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                // Gesture filter
                Text('By Gesture',
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: _filterGesture == 'All',
                      onSelected: (selected) {
                        setState(() => _filterGesture = 'All');
                        Navigator.pop(context);
                        _loadHistory();
                      },
                    ),
                    ..._stats.keys.take(10).map((gesture) {
                      return FilterChip(
                        label: Text(gesture),
                        selected: _filterGesture == gesture,
                        onSelected: (selected) {
                          setState(() => _filterGesture = gesture);
                          Navigator.pop(context);
                          _loadHistory();
                        },
                      );
                    }),
                  ],
                ),

                const SizedBox(height: 24),

                // Date filter
                Text('By Date', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _filterDate ?? DateTime.now(),
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 365),
                      ),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => _filterDate = date);
                      _loadHistory();
                    }
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Select Date'),
                ),
                // Add extra padding at bottom for safe area
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
          'Are you sure you want to clear all detection history? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await DatabaseService.instance.clearGestureHistory();
              Navigator.pop(context);
              _loadHistory();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showHistoryDetail(BuildContext context, GestureHistoryModel item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                24, 24, 24, MediaQuery.of(context).viewPadding.bottom + 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      item.gesture.length == 1
                          ? item.gesture
                          : item.gesture.substring(0, 2),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  GestureLabels.getDisplayName(item.gesture),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                _buildDetailRow(
                  'Category',
                  GestureLabels.getCategory(item.gesture),
                ),
                _buildDetailRow('Confidence', item.confidenceString),
                _buildDetailRow(
                    'Time', DateFormat.jms().format(item.timestamp)),
                _buildDetailRow(
                  'Date',
                  DateFormat.yMMMMd().format(item.timestamp),
                ),
                _buildDetailRow('Mode', item.mode.toUpperCase()),
                const SizedBox(height: 24),
                TextButton.icon(
                  onPressed: () async {
                    await DatabaseService.instance
                        .deleteGestureHistory(item.id!);
                    Navigator.pop(context);
                    _loadHistory();
                  },
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
