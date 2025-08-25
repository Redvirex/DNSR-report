import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/supabase_service.dart';

enum SearchCriteria { email, phone, name }

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  List<UserProfile> _allUsers = [];
  List<UserProfile> _filteredUsers = [];
  UserProfile? _selectedUser;
  bool _isLoading = true;
  String _searchQuery = '';
  SearchCriteria _searchCriteria = SearchCriteria.email;

  // Pagination state
  int _currentPage = 1;
  int _usersPerPage = 20;
  int _totalUsers = 0;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers({bool resetPage = false}) async {
    setState(() => _isLoading = true);
    try {
      if (resetPage) _currentPage = 1;

      final offset = (_currentPage - 1) * _usersPerPage;

      // Load users and total count in parallel
      final results = await Future.wait([
        AdminSupabaseService.instance.getAllUsers(
          limit: _usersPerPage,
          offset: offset,
        ),
        AdminSupabaseService.instance.getUsersCount(),
      ]);

      final users = results[0] as List<UserProfile>;
      final totalCount = results[1] as int;

      setState(() {
        _allUsers = users;
        _filteredUsers = users;
        _totalUsers = totalCount;
        _isLoading = false;
      });

      // Apply current search filter if any
      if (_searchQuery.isNotEmpty) {
        _filterUsers();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading users: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _filterUsers();
    });
  }

  void _filterUsers() {
    if (_searchQuery.isEmpty) {
      _filteredUsers = _allUsers;
      return;
    }

    _filteredUsers = _allUsers.where((user) {
      switch (_searchCriteria) {
        case SearchCriteria.email:
          return user.email.toLowerCase().contains(_searchQuery);
        case SearchCriteria.phone:
          if (user.numeroTelephone == null) return false;

          final userPhone = user.numeroTelephone!.toLowerCase();
          final searchQuery = _searchQuery.toLowerCase().trim();

          // Direct match first
          if (userPhone.contains(searchQuery)) {
            return true;
          }

          // Handle Algerian phone number formats
          if (searchQuery.isNotEmpty) {
            // If user enters number starting with 0 (Algerian local format: 0XXXXXXXXX)
            if (searchQuery.startsWith('0')) {
              // Convert 0XXXXXXXXX to +213XXXXXXXXX (remove 0, add +213)
              final withCountryCode = '+213${searchQuery.substring(1)}';
              if (userPhone.contains(withCountryCode)) {
                return true;
              }
              // Also try without + symbol
              final withoutPlus = '213${searchQuery.substring(1)}';
              if (userPhone.contains(withoutPlus)) {
                return true;
              }
            }
            // If user enters international format starting with +213
            else if (searchQuery.startsWith('+213')) {
              // Already in correct format, try direct match (already done above)
              // Also try converting to local format with 0
              if (searchQuery.length > 4) {
                final localFormat = '0${searchQuery.substring(4)}';
                if (userPhone.contains(localFormat)) {
                  return true;
                }
              }
            }
            // If user enters format starting with 213 (without +)
            else if (searchQuery.startsWith('213')) {
              // Try with + prefix
              final withPlus = '+$searchQuery';
              if (userPhone.contains(withPlus)) {
                return true;
              }
              // Try converting to local format with 0
              if (searchQuery.length > 3) {
                final localFormat = '0${searchQuery.substring(3)}';
                if (userPhone.contains(localFormat)) {
                  return true;
                }
              }
            }
            // If user enters just the number without any prefix
            else {
              // Try with +213 prefix
              final withCountryCode = '+213$searchQuery';
              if (userPhone.contains(withCountryCode)) {
                return true;
              }
              // Try with 213 prefix (without +)
              final withoutPlus = '213$searchQuery';
              if (userPhone.contains(withoutPlus)) {
                return true;
              }
              // Try with 0 prefix (local format)
              final withZero = '0$searchQuery';
              if (userPhone.contains(withZero)) {
                return true;
              }
            }
          }

          return false;
        case SearchCriteria.name:
          final fullName = '${user.prenom ?? ''} ${user.nom ?? ''}'
              .toLowerCase();
          return fullName.contains(_searchQuery);
      }
    }).toList();
  }

  void _updateSearchCriteria(SearchCriteria criteria) {
    setState(() {
      _searchCriteria = criteria;
      _filterUsers();
    });
  }

  void _selectUser(UserProfile user) {
    setState(() {
      _selectedUser = user;
    });
  }

  // Pagination methods
  void _goToPage(int page) {
    if (page >= 1 && page <= _getTotalPages()) {
      setState(() {
        _currentPage = page;
      });
      _loadUsers();
    }
  }

  void _goToFirstPage() => _goToPage(1);
  void _goToLastPage() => _goToPage(_getTotalPages());
  void _goToPreviousPage() => _goToPage(_currentPage - 1);
  void _goToNextPage() => _goToPage(_currentPage + 1);

  int _getTotalPages() {
    return (_totalUsers / _usersPerPage).ceil();
  }

  bool _canGoToPrevious() => _currentPage > 1;
  bool _canGoToNext() => _currentPage < _getTotalPages();

  void _changeUsersPerPage(int newSize) {
    setState(() {
      _usersPerPage = newSize;
      _currentPage = 1;
    });
    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Main content row
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Users List Panel
                Expanded(
                  flex: _selectedUser != null ? 2 : 1,
                  child: _buildUsersListPanel(),
                ),

                // User Details Panel
                if (_selectedUser != null) ...[
                  const SizedBox(width: 16),
                  Expanded(flex: 1, child: _buildUserDetailsPanel()),
                ],
              ],
            ),
          ),

          // Pagination Controls at bottom
          if (_totalUsers > 0) ...[
            const SizedBox(height: 16),
            _buildPaginationControls(),
          ],
        ],
      ),
    );
  }

  Widget _buildUsersListPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.people, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'User Management',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Column(
              children: [
                // Search Input
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: _getSearchHintText(),
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),

                const SizedBox(height: 12),

                // Search Criteria Chips
                Row(
                  children: [
                    Text(
                      'Search by:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        children: SearchCriteria.values.map((criteria) {
                          final isSelected = _searchCriteria == criteria;
                          return FilterChip(
                            label: Text(
                              _getCriteriaLabel(criteria),
                              style: TextStyle(
                                fontSize: 11,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey[700],
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (_) => _updateSearchCriteria(criteria),
                            selectedColor: Colors.blue,
                            backgroundColor: Colors.grey.shade200,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Users List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchQuery.isNotEmpty
                              ? Icons.search_off
                              : Icons.people_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No users found matching your search'
                              : 'No users available',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      return _buildUserCard(user);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(UserProfile user) {
    final isSelected = _selectedUser?.id == user.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isSelected ? 3 : 1,
      color: isSelected ? Colors.blue.shade50 : Colors.white,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getUserStatusColor(user.status),
          child: Text(
            _getUserInitials(user),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          _getUserDisplayName(user),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            if (user.numeroTelephone != null) Text(user.numeroTelephone!),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildStatusChip(user.status),
                const SizedBox(width: 8),
                _buildRoleChip(user.role),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _selectUser(user),
              tooltip: 'View details',
            ),
          ],
        ),
        onTap: () => _selectUser(user),
      ),
    );
  }

  Widget _buildPaginationControls() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Page size selector
          Row(
            children: [
              Text(
                'Show:',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: _usersPerPage,
                underline: const SizedBox(),
                items: [10, 20, 50, 100].map((size) {
                  return DropdownMenuItem(value: size, child: Text('$size'));
                }).toList(),
                onChanged: (size) {
                  if (size != null) _changeUsersPerPage(size);
                },
              ),
              const SizedBox(width: 4),
              Text(
                'per page',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),

          const Spacer(),

          // Pagination buttons
          Row(
            children: [
              // First page
              IconButton(
                onPressed: _canGoToPrevious() ? _goToFirstPage : null,
                icon: const Icon(Icons.first_page),
                tooltip: 'First page',
              ),

              // Previous page
              IconButton(
                onPressed: _canGoToPrevious() ? _goToPreviousPage : null,
                icon: const Icon(Icons.chevron_left),
                tooltip: 'Previous page',
              ),

              // Page numbers
              ...List.generate(_getTotalPages() > 5 ? 5 : _getTotalPages(), (
                index,
              ) {
                int pageNumber;
                if (_getTotalPages() <= 5) {
                  pageNumber = index + 1;
                } else {
                  // Show pages around current page
                  int start = (_currentPage - 2).clamp(1, _getTotalPages() - 4);
                  pageNumber = start + index;
                }

                final isCurrentPage = pageNumber == _currentPage;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: TextButton(
                    onPressed: () => _goToPage(pageNumber),
                    style: TextButton.styleFrom(
                      backgroundColor: isCurrentPage ? Colors.blue : null,
                      foregroundColor: isCurrentPage
                          ? Colors.white
                          : Colors.blue,
                      minimumSize: const Size(40, 40),
                    ),
                    child: Text('$pageNumber'),
                  ),
                );
              }),

              // Next page
              IconButton(
                onPressed: _canGoToNext() ? _goToNextPage : null,
                icon: const Icon(Icons.chevron_right),
                tooltip: 'Next page',
              ),

              // Last page
              IconButton(
                onPressed: _canGoToNext() ? _goToLastPage : null,
                icon: const Icon(Icons.last_page),
                tooltip: 'Last page',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserDetailsPanel() {
    if (_selectedUser == null) return const SizedBox.shrink();

    final user = _selectedUser!;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: _getUserStatusColor(user.status),
                  child: Text(
                    _getUserInitials(user),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getUserDisplayName(user),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user.email,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _selectedUser = null),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status and Role
                  Row(
                    children: [
                      _buildStatusChip(user.status),
                      const SizedBox(width: 8),
                      _buildRoleChip(user.role),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // User Information
                  _buildDetailSection('Personal Information', [
                    _buildDetailRow('User ID', '${user.id.substring(0, 8)}...'),
                    _buildDetailRow(
                      'First Name',
                      user.prenom ?? 'Not provided',
                    ),
                    _buildDetailRow('Last Name', user.nom ?? 'Not provided'),
                    _buildDetailRow('Email', user.email),
                    _buildDetailRow(
                      'Phone Number',
                      user.numeroTelephone ?? 'Not provided',
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Account Information
                  _buildDetailSection('Account Information', [
                    _buildDetailRow('Role', _getRoleDisplayName(user.role)),
                    _buildDetailRow(
                      'Status',
                      _getStatusDisplayName(user.status),
                    ),
                    if (user.createdAt != null)
                      _buildDetailRow(
                        'Registration Date',
                        user.createdAt!.toString().substring(0, 19),
                      ),
                    if (user.updatedAt != null)
                      _buildDetailRow(
                        'Last Updated',
                        user.updatedAt!.toString().substring(0, 19),
                      ),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(StatutUtilisateur status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getUserStatusColor(status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getUserStatusColor(status), width: 1),
      ),
      child: Text(
        _getStatusDisplayName(status),
        style: TextStyle(
          color: _getUserStatusColor(status),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildRoleChip(RoleUtilisateur role) {
    final color = role == RoleUtilisateur.ADMIN ? Colors.purple : Colors.blue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        _getRoleDisplayName(role),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _getCriteriaLabel(SearchCriteria criteria) {
    switch (criteria) {
      case SearchCriteria.email:
        return 'Email';
      case SearchCriteria.phone:
        return 'Phone';
      case SearchCriteria.name:
        return 'Name';
    }
  }

  String _getSearchHintText() {
    switch (_searchCriteria) {
      case SearchCriteria.email:
        return 'Search by email...';
      case SearchCriteria.phone:
        return 'Search by phone (0XXXXXXXXX or +213XXXXXXXXX)...';
      case SearchCriteria.name:
        return 'Search by name...';
    }
  }

  String _getUserDisplayName(UserProfile user) {
    final firstName = user.prenom ?? '';
    final lastName = user.nom ?? '';
    if (firstName.isEmpty && lastName.isEmpty) {
      return user.email.split('@').first;
    }
    return '$firstName $lastName'.trim();
  }

  String _getUserInitials(UserProfile user) {
    final firstName = user.prenom ?? '';
    final lastName = user.nom ?? '';
    if (firstName.isEmpty && lastName.isEmpty) {
      return user.email.substring(0, 1).toUpperCase();
    }
    return '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'
        .toUpperCase();
  }

  Color _getUserStatusColor(StatutUtilisateur status) {
    switch (status) {
      case StatutUtilisateur.ACTIVE:
        return Colors.green;
      case StatutUtilisateur.DEACTIVATED:
        return Colors.red;
    }
  }

  String _getStatusDisplayName(StatutUtilisateur status) {
    switch (status) {
      case StatutUtilisateur.ACTIVE:
        return 'Active';
      case StatutUtilisateur.DEACTIVATED:
        return 'Deactivated';
    }
  }

  String _getRoleDisplayName(RoleUtilisateur role) {
    switch (role) {
      case RoleUtilisateur.ADMIN:
        return 'Administrator';
      case RoleUtilisateur.CITOYEN:
        return 'Citizen';
    }
  }
}
