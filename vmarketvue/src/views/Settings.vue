<template>
    <div class="card">
        <header class="card-header">
            <p class="card-header-title">
                Account Settings
            </p>
        </header>
        <div class="card-content">
            <div v-if="errors.length" class="notification is-danger">
                <p v-for="error in errors" :key="error">{{ error }}</p>
            </div>
            <div v-if="success" class="notification is-success">
                <p>{{ success }}</p>
            </div>

            <div class="tabs">
                <ul>
                    <li :class="{'is-active': activeTab === 'preferences'}">
                        <a @click="activeTab = 'preferences'">Preferences</a>
                    </li>
                    <li :class="{'is-active': activeTab === 'notifications'}">
                        <a @click="activeTab = 'notifications'">Notifications</a>
                    </li>
                    <li :class="{'is-active': activeTab === 'security'}">
                        <a @click="activeTab = 'security'">Security</a>
                    </li>
                </ul>
            </div>

            <div v-if="activeTab === 'preferences'" class="tab-content">
                <form @submit.prevent="savePreferences">
                    <div class="field">
                        <label class="label">Language</label>
                        <div class="control">
                            <div class="select is-fullwidth">
                                <select v-model="settings.language">
                                    <option value="en">English</option>
                                    <option value="es">Spanish</option>
                                    <option value="fr">French</option>
                                    <option value="de">German</option>
                                </select>
                            </div>
                        </div>
                    </div>

                    <div class="field">
                        <label class="label">Currency</label>
                        <div class="control">
                            <div class="select is-fullwidth">
                                <select v-model="settings.currency">
                                    <option value="USD">US Dollar ($)</option>
                                    <option value="EUR">Euro (€)</option>
                                    <option value="GBP">British Pound (£)</option>
                                    <option value="JPY">Japanese Yen (¥)</option>
                                    <option value="CAD">Canadian Dollar (C$)</option>
                                </select>
                            </div>
                        </div>
                    </div>

                    <div class="field">
                        <div class="control">
                            <label class="checkbox">
                                <input type="checkbox" v-model="settings.dark_mode">
                                Dark Mode
                            </label>
                        </div>
                    </div>

                    <div class="field mt-5">
                        <div class="control">
                            <button type="submit" class="button is-primary" :class="{'is-loading': isSubmitting}">
                                Save Preferences
                            </button>
                        </div>
                    </div>
                </form>
            </div>

            <div v-if="activeTab === 'notifications'" class="tab-content">
                <form @submit.prevent="saveNotifications">
                    <div class="field">
                        <div class="control">
                            <label class="checkbox">
                                <input type="checkbox" v-model="settings.email_notifications">
                                Email Notifications
                            </label>
                            <p class="help">Receive order updates and promotional emails</p>
                        </div>
                    </div>

                    <div class="field">
                        <div class="control">
                            <label class="checkbox">
                                <input type="checkbox" v-model="settings.order_updates">
                                Order Updates
                            </label>
                            <p class="help">Receive notifications about your order status</p>
                        </div>
                    </div>

                    <div class="field">
                        <div class="control">
                            <label class="checkbox">
                                <input type="checkbox" v-model="settings.promotional_emails">
                                Promotional Emails
                            </label>
                            <p class="help">Receive emails about sales, new products, and offers</p>
                        </div>
                    </div>

                    <div class="field">
                        <div class="control">
                            <label class="checkbox">
                                <input type="checkbox" v-model="settings.newsletter">
                                Newsletter
                            </label>
                            <p class="help">Receive our weekly newsletter</p>
                        </div>
                    </div>

                    <div class="field mt-5">
                        <div class="control">
                            <button type="submit" class="button is-primary" :class="{'is-loading': isSubmitting}">
                                Save Notification Settings
                            </button>
                        </div>
                    </div>
                </form>
            </div>

            <div v-if="activeTab === 'security'" class="tab-content">
                <form @submit.prevent="changePassword">
                    <div class="field">
                        <label class="label">Current Password</label>
                        <div class="control">
                            <input type="password" class="input" v-model="passwordData.current_password" placeholder="Enter your current password">
                        </div>
                    </div>

                    <div class="field">
                        <label class="label">New Password</label>
                        <div class="control">
                            <input type="password" class="input" v-model="passwordData.new_password" placeholder="Enter a new password">
                        </div>
                        <p class="help">Password must be at least 8 characters long</p>
                    </div>

                    <div class="field">
                        <label class="label">Confirm New Password</label>
                        <div class="control">
                            <input type="password" class="input" v-model="passwordData.confirm_password" placeholder="Confirm your new password">
                        </div>
                    </div>

                    <div class="field mt-5">
                        <div class="control">
                            <button type="submit" class="button is-primary" :class="{'is-loading': isSubmitting}">
                                Change Password
                            </button>
                        </div>
                    </div>
                </form>

                <hr class="mt-6">

                <h3 class="title is-5 mt-5 has-text-danger">Danger Zone</h3>
                <div class="box has-background-danger-light">
                    <h4 class="subtitle is-6">Delete Account</h4>
                    <p class="mb-4">Once you delete your account, there is no going back. Please be certain.</p>
                    <button class="button is-danger" @click="showDeleteAccountModal = true">
                        Delete Account
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Delete Account Modal -->
    <div class="modal" :class="{'is-active': showDeleteAccountModal}">
        <div class="modal-background" @click="showDeleteAccountModal = false"></div>
        <div class="modal-card">
            <header class="modal-card-head">
                <p class="modal-card-title">Delete Account</p>
                <button class="delete" aria-label="close" @click="showDeleteAccountModal = false"></button>
            </header>
            <section class="modal-card-body">
                <p>Are you sure you want to delete your account? This action <strong>cannot be undone</strong>.</p>
                <p class="mt-4">Please enter your password to confirm:</p>
                <div class="field mt-3">
                    <div class="control">
                        <input type="password" class="input" v-model="deleteConfirmPassword" placeholder="Enter your password">
                    </div>
                </div>
            </section>
            <footer class="modal-card-foot">
                <button class="button is-danger" @click="deleteAccount" :class="{'is-loading': isDeletingAccount}">
                    Delete My Account
                </button>
                <button class="button" @click="showDeleteAccountModal = false">Cancel</button>
            </footer>
        </div>
    </div>
</template>

<script>
import axios from 'axios'

export default {
    name: 'Settings',
    data() {
        return {
            activeTab: 'preferences',
            settings: {
                language: 'en',
                currency: 'USD',
                dark_mode: false,
                email_notifications: true,
                order_updates: true,
                promotional_emails: true,
                newsletter: true
            },
            passwordData: {
                current_password: '',
                new_password: '',
                confirm_password: ''
            },
            errors: [],
            success: '',
            isSubmitting: false,
            showDeleteAccountModal: false,
            deleteConfirmPassword: '',
            isDeletingAccount: false
        }
    },
    mounted() {
        document.title = 'Account Settings | V-Market'
        this.getSettings()
    },
    methods: {
        async getSettings() {
            this.$store.commit('setIsLoading', true)
            try {
                const response = await axios.get('/api/v1/users/settings/')
                this.settings = { ...this.settings, ...response.data }
            } catch (error) {
                console.log(error)
            } finally {
                this.$store.commit('setIsLoading', false)
            }
        },
        async savePreferences() {
            this.errors = []
            this.success = ''
            this.isSubmitting = true
            
            try {
                await axios.patch('/api/v1/users/settings/', {
                    language: this.settings.language,
                    currency: this.settings.currency,
                    dark_mode: this.settings.dark_mode
                })
                
                this.success = 'Preferences saved successfully'
            } catch (error) {
                if (error.response && error.response.data) {
                    for (const [key, value] of Object.entries(error.response.data)) {
                        this.errors.push(`${key}: ${value}`)
                    }
                } else {
                    this.errors.push('An error occurred while saving preferences')
                }
            } finally {
                this.isSubmitting = false
            }
        },
        async saveNotifications() {
            this.errors = []
            this.success = ''
            this.isSubmitting = true
            
            try {
                await axios.patch('/api/v1/users/settings/', {
                    email_notifications: this.settings.email_notifications,
                    order_updates: this.settings.order_updates,
                    promotional_emails: this.settings.promotional_emails,
                    newsletter: this.settings.newsletter
                })
                
                this.success = 'Notification settings saved successfully'
            } catch (error) {
                if (error.response && error.response.data) {
                    for (const [key, value] of Object.entries(error.response.data)) {
                        this.errors.push(`${key}: ${value}`)
                    }
                } else {
                    this.errors.push('An error occurred while saving notification settings')
                }
            } finally {
                this.isSubmitting = false
            }
        },
        async changePassword() {
            this.errors = []
            this.success = ''
            this.isSubmitting = true
            
            // Validate
            if (!this.passwordData.current_password) {
                this.errors.push('Current password is required')
                this.isSubmitting = false
                return
            }
            
            if (!this.passwordData.new_password) {
                this.errors.push('New password is required')
                this.isSubmitting = false
                return
            }
            
            if (this.passwordData.new_password.length < 8) {
                this.errors.push('New password must be at least 8 characters long')
                this.isSubmitting = false
                return
            }
            
            if (this.passwordData.new_password !== this.passwordData.confirm_password) {
                this.errors.push('Passwords do not match')
                this.isSubmitting = false
                return
            }
            
            try {
                await axios.post('/api/v1/users/set_password/', {
                    current_password: this.passwordData.current_password,
                    new_password: this.passwordData.new_password
                })
                
                // Clear form
                this.passwordData = {
                    current_password: '',
                    new_password: '',
                    confirm_password: ''
                }
                
                this.success = 'Password changed successfully'
            } catch (error) {
                if (error.response && error.response.data) {
                    for (const [key, value] of Object.entries(error.response.data)) {
                        this.errors.push(`${key}: ${value}`)
                    }
                } else {
                    this.errors.push('An error occurred while changing password')
                }
            } finally {
                this.isSubmitting = false
            }
        },
        async deleteAccount() {
            if (!this.deleteConfirmPassword) {
                this.errors = ['Please enter your password to confirm account deletion']
                return
            }
            
            this.isDeletingAccount = true
            this.errors = []
            
            try {
                await axios.post('/api/v1/users/delete_account/', {
                    password: this.deleteConfirmPassword
                })
                
                // Logout and redirect
                axios.defaults.headers.common["Authorization"] = ""
                localStorage.removeItem("token")
                localStorage.removeItem("username")
                localStorage.removeItem("userid")
                this.$store.commit('removeToken')
                
                // Inform user
                this.$store.commit('setNotification', {
                    message: 'Your account has been deleted successfully',
                    type: 'is-info'
                })
                
                // Redirect to home
                this.$router.push('/')
                
            } catch (error) {
                if (error.response && error.response.data) {
                    for (const [key, value] of Object.entries(error.response.data)) {
                        this.errors.push(`${key}: ${value}`)
                    }
                } else {
                    this.errors.push('An error occurred while deleting your account')
                }
                
                this.showDeleteAccountModal = false
            } finally {
                this.isDeletingAccount = false
            }
        }
    }
}
</script>

<style scoped>
.tab-content {
    padding-top: 1.5rem;
}

.mt-3 {
    margin-top: 0.75rem;
}

.mt-4 {
    margin-top: 1rem;
}

.mt-5 {
    margin-top: 1.5rem;
}

.mt-6 {
    margin-top: 2rem;
}

.mb-4 {
    margin-bottom: 1rem;
}
</style>
