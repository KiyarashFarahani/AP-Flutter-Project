package backend;

import backend.model.Admin;
import backend.model.Song;
import backend.model.User;
import backend.utils.JsonDatabase;
import backend.exceptions.InvalidPasswordException;
import backend.exceptions.InvalidUsernameException;

import javax.swing.*;
import javax.swing.table.DefaultTableModel;
import javax.swing.table.TableCellRenderer;
import java.awt.*;
import java.util.*;
import java.util.List;

public class AdminPanel extends JFrame {
    private Admin currentAdmin;
    private JTable songsTable;
    private JTable usersTable;
    private DefaultTableModel songsModel;
    private DefaultTableModel usersModel;
    private List<Song> allSongs;
    private List<User> allUsers;

    public AdminPanel(Admin admin) {
        this.currentAdmin = admin;
        setupFrame();
        loadData();
        createUI();
        setVisible(true);
    }

    private void setupFrame() {
        setTitle("Admin Panel - " + currentAdmin.getUsername());
        setSize(1200, 800);
        setLocationRelativeTo(null);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        try {
            UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void loadData() {
        allSongs = JsonDatabase.loadSongs();
        allUsers = JsonDatabase.loadUsers();
        if (allSongs == null) allSongs = new ArrayList<>();
        if (allUsers == null) allUsers = new ArrayList<>();

        System.out.println("Loaded " + allUsers.size() + " users");
        System.out.println("Loaded " + allSongs.size() + " songs");
    }

    private void createUI() {
        JTabbedPane tabbedPane = new JTabbedPane();

        JPanel headerPanel = createHeaderPanel();
        add(headerPanel, BorderLayout.NORTH);

        tabbedPane.addTab("Songs by Likes", createSongsPanel());
        tabbedPane.addTab("Users Info", createUsersPanel());

        add(tabbedPane, BorderLayout.CENTER);
    }

    private JPanel createHeaderPanel() {
        JPanel panel = new JPanel(new BorderLayout());
        panel.setBackground(new Color(70, 130, 180));
        panel.setBorder(BorderFactory.createEmptyBorder(10, 15, 10, 15));

        JLabel titleLabel = new JLabel("Admin Control Panel");
        titleLabel.setFont(new Font("Arial", Font.BOLD, 20));
        titleLabel.setForeground(Color.WHITE);
        panel.add(titleLabel, BorderLayout.WEST);

        JButton logoutButton = new JButton("Logout");
        logoutButton.addActionListener(e -> handleLogout());
        panel.add(logoutButton, BorderLayout.EAST);

        return panel;
    }

    private JPanel createSongsPanel() {
        JPanel panel = new JPanel(new BorderLayout());

        songsModel = new DefaultTableModel() {
            @Override
            public boolean isCellEditable(int row, int column) {
                return column == 4;
            }
        };
        songsModel.addColumn("ID");
        songsModel.addColumn("Title");
        songsModel.addColumn("Artist");
        songsModel.addColumn("Likes");
        songsModel.addColumn("Actions");

        songsTable = new JTable(songsModel);
        songsTable.getColumnModel().getColumn(4).setCellRenderer(new ButtonRenderer());
        songsTable.getColumnModel().getColumn(4).setCellEditor(new ButtonEditor(new JCheckBox(), this));

        JButton refreshButton = new JButton("Refresh Songs");
        refreshButton.addActionListener(e -> refreshSongsData());

        panel.add(refreshButton, BorderLayout.NORTH);
        panel.add(new JScrollPane(songsTable), BorderLayout.CENTER);

        refreshSongsData();
        return panel;
    }

    private JPanel createUsersPanel() {
        JPanel panel = new JPanel(new BorderLayout());

        usersModel = new DefaultTableModel() {
            @Override
            public boolean isCellEditable(int row, int column) {
                return column == 4;
            }
        };
        usersModel.addColumn("ID");
        usersModel.addColumn("Username");
        usersModel.addColumn("Theme");
        usersModel.addColumn("Share Permission");
        usersModel.addColumn("Actions");

        usersTable = new JTable(usersModel);
        usersTable.getColumnModel().getColumn(4).setCellRenderer(new ButtonRenderer());
        usersTable.getColumnModel().getColumn(4).setCellEditor(new ButtonEditor(new JCheckBox(), this));

        JButton refreshButton = new JButton("Refresh Users");
        refreshButton.addActionListener(e -> refreshUsersData());

        panel.add(refreshButton, BorderLayout.NORTH);
        panel.add(new JScrollPane(usersTable), BorderLayout.CENTER);

        refreshUsersData();
        return panel;
    }

    private void refreshSongsData() {
        songsModel.setRowCount(0);
        allSongs.sort((s1, s2) -> Integer.compare(s2.getLikes(), s1.getLikes()));

        for (Song song : allSongs) {
            songsModel.addRow(new Object[]{
                    song.getId(),
                    song.getTitle(),
                    song.getArtist(),
                    song.getLikes(),
                    "View Details"
            });
        }
    }

    private void refreshUsersData() {
        usersModel.setRowCount(0);
        System.out.println("refreshUsersData called, allUsers size: " + allUsers.size());

        for (User user : allUsers) {
            System.out.println("Adding user to table: " + user.getUsername());
            usersModel.addRow(new Object[]{
                    user.getId(),
                    user.getUsername(),
                    user.getTheme(),
                    user.isSharePermission() ? "Yes" : "No",
                    "Manage User"
            });
        }
    }

    private void handleLogout() {
        int choice = JOptionPane.showConfirmDialog(this,
                "Are you sure you want to logout?",
                "Logout Confirmation",
                JOptionPane.YES_NO_OPTION);

        if (choice == JOptionPane.YES_OPTION) {
            dispose();
            Admin newAdmin = showLoginDialog();
            if (newAdmin != null) {
                new AdminPanel(newAdmin);
            } else {
                System.exit(0);
            }
        }
    }

    private void showSongDetails(Song song) {
        JDialog dialog = new JDialog(this, "Song Details", true);
        dialog.setSize(400, 300);
        dialog.setLocationRelativeTo(this);
        dialog.setLayout(new BorderLayout());

        JPanel contentPanel = new JPanel(new GridLayout(0, 2, 10, 5));
        contentPanel.setBorder(BorderFactory.createEmptyBorder(20, 20, 20, 20));

        contentPanel.add(new JLabel("Title:"));
        contentPanel.add(new JLabel(song.getTitle()));
        contentPanel.add(new JLabel("Artist:"));
        contentPanel.add(new JLabel(song.getArtist()));
        contentPanel.add(new JLabel("Album:"));
        contentPanel.add(new JLabel(song.getAlbum()));
        contentPanel.add(new JLabel("Genre:"));
        contentPanel.add(new JLabel(song.getGenre()));
        contentPanel.add(new JLabel("Duration:"));
        contentPanel.add(new JLabel(song.getDuration() + " seconds"));
        contentPanel.add(new JLabel("Year:"));
        contentPanel.add(new JLabel(String.valueOf(song.getYear())));
        contentPanel.add(new JLabel("Likes:"));
        contentPanel.add(new JLabel(String.valueOf(song.getLikes())));
        contentPanel.add(new JLabel("Play Count:"));
        contentPanel.add(new JLabel(String.valueOf(song.getPlayCount())));

        dialog.add(contentPanel, BorderLayout.CENTER);

        JButton closeButton = new JButton("Close");
        closeButton.addActionListener(e -> dialog.dispose());
        dialog.add(closeButton, BorderLayout.SOUTH);

        dialog.setVisible(true);
    }

    private void showUserManagement(User user) {
        System.out.println("showUserManagement called for user: " + user.getUsername());
        JDialog dialog = new JDialog(this, "User Management - " + user.getUsername(), true);
        dialog.setSize(500, 400);
        dialog.setLocationRelativeTo(this);
        dialog.setLayout(new BorderLayout());

        JPanel contentPanel = new JPanel(new GridLayout(0, 2, 10, 5));
        contentPanel.setBorder(BorderFactory.createEmptyBorder(20, 20, 20, 20));

        contentPanel.add(new JLabel("ID:"));
        contentPanel.add(new JLabel(String.valueOf(user.getId())));
        contentPanel.add(new JLabel("Username:"));
        contentPanel.add(new JLabel(user.getUsername()));
        contentPanel.add(new JLabel("Theme:"));
        contentPanel.add(new JLabel(user.getTheme().toString()));
        contentPanel.add(new JLabel("Share Permission:"));
        contentPanel.add(new JLabel(user.isSharePermission() ? "Yes" : "No"));

        dialog.add(contentPanel, BorderLayout.CENTER);

        JPanel buttonPanel = new JPanel(new FlowLayout());

        JButton deleteButton = new JButton("Delete Account");
        deleteButton.addActionListener(e -> {
            int choice = JOptionPane.showConfirmDialog(dialog,
                    "Are you sure you want to delete this user's account? This action cannot be undone.",
                    "Delete Confirmation",
                    JOptionPane.YES_NO_OPTION);

            if (choice == JOptionPane.YES_OPTION) {
                try {
                    currentAdmin.deleteUserAccount(user);
                    JsonDatabase.saveUsers();
                    allUsers = JsonDatabase.loadUsers();
                    refreshUsersData();
                    dialog.dispose();
                    JOptionPane.showMessageDialog(this, "User account deleted successfully!");
                } catch (Exception ex) {
                    JOptionPane.showMessageDialog(this, "Error deleting user account: " + ex.getMessage());
                }
            }
        });
        buttonPanel.add(deleteButton);

        JButton closeButton = new JButton("Close");
        closeButton.addActionListener(e -> dialog.dispose());
        buttonPanel.add(closeButton);

        dialog.add(buttonPanel, BorderLayout.SOUTH);
        dialog.setVisible(true);
    }

    private User findUserById(int userId) {
        for (User user : allUsers) {
            if (user.getId() == userId) {
                return user;
            }
        }
        return null;
    }

    private Song findSongById(int songId) {
        for (Song song : allSongs) {
            if (song.getId() == songId) {
                return song;
            }
        }
        return null;
    }

    private static Admin showLoginDialog() {
        JDialog loginDialog = new JDialog((JFrame) null, "Admin Authentication", true);
        loginDialog.setDefaultCloseOperation(JDialog.DISPOSE_ON_CLOSE);
        loginDialog.setSize(400, 300);
        loginDialog.setLocationRelativeTo(null);
        loginDialog.setResizable(false);

        JTextField usernameField = new JTextField(20);
        JPasswordField passwordField = new JPasswordField(20);
        JButton loginButton = new JButton("Login");
        JButton signupButton = new JButton("Sign Up");
        JButton switchModeButton = new JButton("Switch to Sign Up");

        loginButton.setBackground(new Color(70, 130, 180));
        loginButton.setForeground(Color.BLACK);
        loginButton.setFocusPainted(false);

        signupButton.setBackground(new Color(46, 139, 87));
        signupButton.setForeground(Color.BLACK);
        signupButton.setFocusPainted(false);

        switchModeButton.setBackground(new Color(128, 128, 128));
        switchModeButton.setForeground(Color.BLACK);
        switchModeButton.setFocusPainted(false);

        loginDialog.setLayout(new BorderLayout());
        JPanel mainPanel = new JPanel();
        mainPanel.setLayout(new GridBagLayout());
        mainPanel.setBorder(BorderFactory.createEmptyBorder(20, 20, 20, 20));

        GridBagConstraints gbc = new GridBagConstraints();
        gbc.insets = new Insets(5, 5, 5, 5);
        gbc.fill = GridBagConstraints.HORIZONTAL;

        JLabel titleLabel = new JLabel("Admin Panel Authentication");
        titleLabel.setFont(new Font("Arial", Font.BOLD, 18));
        titleLabel.setHorizontalAlignment(SwingConstants.CENTER);
        gbc.gridx = 0;
        gbc.gridy = 0;
        gbc.gridwidth = 2;
        mainPanel.add(titleLabel, gbc);

        gbc.gridwidth = 1;
        gbc.gridy = 1;
        gbc.gridx = 0;
        mainPanel.add(new JLabel("Username/Email:"), gbc);

        gbc.gridx = 1;
        mainPanel.add(usernameField, gbc);

        gbc.gridy = 2;
        gbc.gridx = 0;
        mainPanel.add(new JLabel("Password:"), gbc);

        gbc.gridx = 1;
        mainPanel.add(passwordField, gbc);

        JPanel buttonPanel = new JPanel();
        buttonPanel.setLayout(new FlowLayout(FlowLayout.CENTER, 10, 10));
        buttonPanel.add(loginButton);
        buttonPanel.add(signupButton);
        buttonPanel.add(switchModeButton);

        gbc.gridy = 3;
        gbc.gridx = 0;
        gbc.gridwidth = 2;
        mainPanel.add(buttonPanel, gbc);

        loginDialog.add(mainPanel, BorderLayout.CENTER);

        List<Admin> adminList = JsonDatabase.loadAdmins();

        try {
            adminList.add(new Admin("admin@admin.com", "Admin123!"));
        } catch (Exception e) {
            e.printStackTrace();
        }

        boolean[] isLoginMode = {true};
        Admin[] result = {null};

        switchModeButton.addActionListener(e -> {
            isLoginMode[0] = !isLoginMode[0];
            if (isLoginMode[0]) {
                signupButton.setVisible(false);
                loginButton.setVisible(true);
                switchModeButton.setText("Switch to Sign Up");
                loginDialog.setTitle("Admin Login");
            } else {
                signupButton.setVisible(true);
                loginButton.setVisible(false);
                switchModeButton.setText("Switch to Login");
                loginDialog.setTitle("Admin Sign Up");
            }
            loginDialog.revalidate();
            loginDialog.repaint();
        });

        loginButton.addActionListener(e -> {
            String username = usernameField.getText().trim();
            String password = new String(passwordField.getPassword());

            if (username.isEmpty() || password.isEmpty()) {
                JOptionPane.showMessageDialog(loginDialog,
                        "Please enter both username and password.",
                        "Login Error",
                        JOptionPane.ERROR_MESSAGE);
                return;
            }
            // Inline validation for username and password format
            String usernameError = Validator.getUsernameValidationError(username);
            if (usernameError != null) {
                JOptionPane.showMessageDialog(loginDialog,
                        usernameError,
                        "Login Error",
                        JOptionPane.ERROR_MESSAGE);
                return;
            }
            String passwordError = Validator.getPasswordValidationError(password, username);
            if (passwordError != null) {
                JOptionPane.showMessageDialog(loginDialog,
                        passwordError,
                        "Login Error",
                        JOptionPane.ERROR_MESSAGE);
                return;
            }

            Admin admin = JsonDatabase.findAdminByUsername(username);
            if (admin != null && admin.getPassword().equals(password)) {
                result[0] = admin;
                JOptionPane.showMessageDialog(loginDialog,
                        "Login successful! Welcome, " + admin.getUsername(),
                        "Success",
                        JOptionPane.INFORMATION_MESSAGE);
                loginDialog.dispose();
            } else {
                JOptionPane.showMessageDialog(loginDialog,
                        "Invalid username or password. Please try again.",
                        "Login Error",
                        JOptionPane.ERROR_MESSAGE);
                passwordField.setText("");
                passwordField.requestFocusInWindow();
            }
        });

        signupButton.addActionListener(e -> {
            String username = usernameField.getText().trim();
            String password = new String(passwordField.getPassword());

            if (username.isEmpty() || password.isEmpty()) {
                JOptionPane.showMessageDialog(loginDialog,
                        "Please fill in all fields.",
                        "Sign Up Error",
                        JOptionPane.ERROR_MESSAGE);
                return;
            }
            // Inline validation for username and password format
            String usernameError = Validator.getUsernameValidationError(username);
            if (usernameError != null) {
                JOptionPane.showMessageDialog(loginDialog,
                        usernameError,
                        "Sign Up Error",
                        JOptionPane.ERROR_MESSAGE);
                return;
            }
            String passwordError = Validator.getPasswordValidationError(password, username);
            if (passwordError != null) {
                JOptionPane.showMessageDialog(loginDialog,
                        passwordError,
                        "Sign Up Error",
                        JOptionPane.ERROR_MESSAGE);
                return;
            }

            try {
                if (adminList.contains(new Admin(username,password))) {
                    JOptionPane.showMessageDialog(loginDialog,
                            "An admin with this username already exists.",
                            "Sign Up Error",
                            JOptionPane.ERROR_MESSAGE);
                    return;
                }
            } catch (InvalidPasswordException ex) {
                throw new RuntimeException(ex);
            } catch (InvalidUsernameException ex) {
                throw new RuntimeException(ex);
            }

            try {
                Admin newAdmin = new Admin(username, password);
                adminList.add(newAdmin);
                JsonDatabase.addAdmin(newAdmin);
                JOptionPane.showMessageDialog(loginDialog,
                        "Admin account created successfully! You can now login.",
                        "Success",
                        JOptionPane.INFORMATION_MESSAGE);

                isLoginMode[0] = true;
                signupButton.setVisible(false);
                loginButton.setVisible(true);
                switchModeButton.setText("Switch to Sign Up");
                loginDialog.setTitle("Admin Login");

            } catch (Exception ex) {
                JOptionPane.showMessageDialog(loginDialog,
                        "Error creating admin account: " + ex.getMessage(),
                        "Sign Up Error",
                        JOptionPane.ERROR_MESSAGE);
            }
        });
        signupButton.setVisible(false);
        switchModeButton.setText("Switch to Sign Up");
        loginDialog.setTitle("Admin Login");

        loginDialog.setVisible(true);

        return result[0];
    }

    public static void main(String[] args) {
        try {
            try {
                UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
            } catch (Exception e) {
                e.printStackTrace();
            }

            SwingUtilities.invokeLater(() -> {
                Admin admin = showLoginDialog();
                if (admin != null) {
                    new AdminPanel(admin);
                } else {
                    System.exit(0);
                }
            });

        } catch (Exception e) {
            e.printStackTrace();
            JOptionPane.showMessageDialog(null, "Error creating admin panel: " + e.getMessage());
            System.exit(1);
        }
    }

    static class ButtonRenderer extends JButton implements TableCellRenderer {
        public ButtonRenderer() {
            setOpaque(true);
        }

        @Override
        public Component getTableCellRendererComponent(JTable table, Object value,
                                                       boolean isSelected, boolean hasFocus, int row, int column) {
            setText((value == null) ? "" : value.toString());
            return this;
        }
    }

    static class ButtonEditor extends DefaultCellEditor {
        protected JButton button;
        private String label;
        private boolean isPushed;
        private int currentRow;
        private AdminPanel adminPanelInstance;

        public ButtonEditor(JCheckBox checkBox, AdminPanel adminPanel) {
            super(checkBox);
            this.adminPanelInstance = adminPanel;
            button = new JButton();
            button.setOpaque(true);
            button.addActionListener(e -> fireEditingStopped());
        }

        @Override
        public Component getTableCellEditorComponent(JTable table, Object value,
                                                     boolean isSelected, int row, int column) {
            label = (value == null) ? "" : value.toString();
            button.setText(label);
            currentRow = row;
            isPushed = true;
            return button;
        }

        @Override
        public Object getCellEditorValue() {
            System.out.println("ButtonEditor.getCellEditorValue called, label: " + label + ", isPushed: " + isPushed);
            if (isPushed) {
                if ("View Details".equals(label)) {
                    System.out.println("View Details clicked for row: " + currentRow);
                    SwingUtilities.invokeLater(() -> {
                        // Get the song ID from the table and find the song by ID
                        int songId = (Integer) adminPanelInstance.songsModel.getValueAt(currentRow, 0);
                        Song song = adminPanelInstance.findSongById(songId);
                        if (song != null) {
                            adminPanelInstance.showSongDetails(song);
                        } else {
                            JOptionPane.showMessageDialog(adminPanelInstance,
                                    "Song not found!", "Error", JOptionPane.ERROR_MESSAGE);
                        }
                    });
                } else if ("Manage User".equals(label)) {
                    System.out.println("Manage User clicked for row: " + currentRow);
                    SwingUtilities.invokeLater(() -> {
                        // Get the user ID from the table and find the user by ID
                        int userId = (Integer) adminPanelInstance.usersModel.getValueAt(currentRow, 0);
                        User user = adminPanelInstance.findUserById(userId);
                        if (user != null) {
                            adminPanelInstance.showUserManagement(user);
                        } else {
                            JOptionPane.showMessageDialog(adminPanelInstance,
                                    "User not found!", "Error", JOptionPane.ERROR_MESSAGE);
                        }
                    });
                }
            }
            isPushed = false;
            return label;
        }

        @Override
        public boolean stopCellEditing() {
            isPushed = false;
            return super.stopCellEditing();
        }
    }
}