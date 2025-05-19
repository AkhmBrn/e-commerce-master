<template>
    <div class="card">
        <header class="card-header">
            <p class="card-header-title">
                Edit Profile
            </p>
        </header>
        <div class="card-content">
            <div v-if="errors.length" class="notification is-danger">
                <p v-for="error in errors" :key="error">{{ error }}</p>
            </div>

            <form @submit.prevent="submitForm">
                <div class="field">
                    <label class="label">Full Name</label>
                    <div class="control">
                        <input 
                            type="text" 
                            class="input" 
                            v-model="userData.name" 
                            placeholder="Enter your full name"
                        >
                    </div>
                </div>

                <div class="field">
                    <label class="label">Email</label>
                    <div class="control">
                        <input 
                            type="email" 
                            class="input" 
                            v-model="userData.email" 
                            placeholder="Enter your email"
                            disabled
                        >
                    </div>
                    <p class="help">Email address cannot be changed</p>
                </div>

                <div class="field">
                    <label class="label">Phone</label>
                    <div class="control">
                        <input 
                            type="tel" 
                            class="input" 
                            v-model="userData.phone" 
                            placeholder="Enter your phone number"
                        >
                    </div>
                </div>

                <div class="field">
                    <div class="control">
                        <button class="button is-primary" type="submit" :class="{'is-loading': isSubmitting}">
                            Save Changes
                        </button>
                    </div>
                </div>
            </form>

            <hr>

            <h3 class="subtitle is-4 mt-5">Change Password</h3>
            <div v-if="passwordErrors.length" class="notification is-danger">
                <p v-for="error in passwordErrors" :key="error">{{ error }}</p>
            </div>
            <div v-if="passwordSuccess" class="notification is-success">
                <p>{{ passwordSuccess }}</p>
            </div>

            <form @submit.prevent="changePassword">
                <div class="field">
                    <label class="label">Current Password</label>
                    <div class="control">
                        <input 
                            type="password" 
                            class="input" 
                            v-model="passwords.current" 
                            placeholder="Enter current password"
                        >
                    </div>
                </div>

                <div class="field">
                    <label class="label">New Password</label>
                    <div class="control">
                        <input 
                            type="password" 
                            class="input" 
                            v-model="passwords.new" 
                            placeholder="Enter new password"
                        >
                    </div>
                </div>

                <div class="field">
                    <label class="label">Confirm New Password</label>
                    <div class="control">
                        <input 
                            type="password" 
                            class="input" 
                            v-model="passwords.confirm" 
                            placeholder="Confirm new password"
                        >
                    </div>
                </div>

                <div class="field">
                    <div class="control">
                        <button class="button is-primary" type="submit" :class="{'is-loading': isChangingPassword}">
                            Change Password
                        </button>
                    </div>
                </div>
            </form>
        </div>
    </div>
</template>

<script>
import axios from 'axios'

export default {
    name: 'Profile',
    data() {
        return {
            userData: {
                name: '',
                email: '',
                phone: ''
            },
            passwords: {
                current: '',
                new: '',
                confirm: ''
            },
            errors: [],
            passwordErrors: [],
            passwordSuccess: '',
            isSubmitting: false,
            isChangingPassword: false
        }
    },
    mounted() {
        document.title = 'Edit Profile | V-Market'
        this.getUserData()
    },
    methods: {
        async getUserData() {
            this.$store.commit('setIsLoading', true)
            await axios
                .get('/api/v1/users/me/')
                .then(response => {
                    this.userData = response.data
                })
                .catch(error => {
                    console.log(error)
                })
            this.$store.commit('setIsLoading', false)
        },
        async submitForm() {
            this.errors = []
            this.isSubmitting = true

            if (!this.userData.name) {
                this.errors.push('Name is required')
                this.isSubmitting = false
                return
            }

            try {
                const response = await axios.patch('/api/v1/users/me/', {
                    name: this.userData.name,
                    phone: this.userData.phone
                })
                
                this.userData = response.data
                
                // Update username in localStorage
                localStorage.setItem('username', this.userData.name)
                
                // Show success notification
                this.$store.commit('setNotification', {
                    message: 'Profile updated successfully',
                    type: 'is-success'
                })
                
            } catch (error) {
                if (error.response) {
                    for (const [key, value] of Object.entries(error.response.data)) {
                        this.errors.push(`${key}: ${value}`)
                    }
                } else {
                    this.errors.push('Something went wrong. Please try again.')
                }
            } finally {
                this.isSubmitting = false
            }
        },
        async changePassword() {
            this.passwordErrors = []
            this.passwordSuccess = ''
            this.isChangingPassword = true

            // Validation
            if (!this.passwords.current) {
                this.passwordErrors.push('Current password is required')
                this.isChangingPassword = false
                return
            }

            if (!this.passwords.new) {
                this.passwordErrors.push('New password is required')
                this.isChangingPassword = false
                return
            }

            if (this.passwords.new.length < 8) {
                this.passwordErrors.push('New password must be at least 8 characters')
                this.isChangingPassword = false
                return
            }

            if (this.passwords.new !== this.passwords.confirm) {
                this.passwordErrors.push('Passwords do not match')
                this.isChangingPassword = false
                return
            }

            try {
                await axios.post('/api/v1/users/set_password/', {
                    current_password: this.passwords.current,
                    new_password: this.passwords.new
                })
                
                // Clear form
                this.passwords = {
                    current: '',
                    new: '',
                    confirm: ''
                }
                
                this.passwordSuccess = 'Password changed successfully'
                
            } catch (error) {
                if (error.response) {
                    for (const [key, value] of Object.entries(error.response.data)) {
                        this.passwordErrors.push(`${key}: ${value}`)
                    }
                } else {
                    this.passwordErrors.push('Something went wrong. Please try again.')
                }
            } finally {
                this.isChangingPassword = false
            }
        }
    }
}
</script>

<style scoped>
.mt-5 {
    margin-top: 1.5rem;
}
</style>
