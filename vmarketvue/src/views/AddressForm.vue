<template>
    <div class="card">
        <header class="card-header">
            <p class="card-header-title">
                {{ isEdit ? 'Edit Address' : 'Add New Address' }}
            </p>
            <router-link to="/my-account/addresses" class="card-header-icon">
                <span class="icon">
                    <i class="fas fa-arrow-left"></i>
                </span>
                <span>Back to Addresses</span>
            </router-link>
        </header>
        <div class="card-content">
            <div v-if="errors.length" class="notification is-danger">
                <p v-for="error in errors" :key="error">{{ error }}</p>
            </div>

            <form @submit.prevent="saveAddress">
                <div class="field">
                    <label class="label">Full Name</label>
                    <div class="control">
                        <input type="text" class="input" v-model="address.name" placeholder="Enter full name">
                    </div>
                </div>

                <div class="field">
                    <label class="label">Address Line 1</label>
                    <div class="control">
                        <input type="text" class="input" v-model="address.address_line1" placeholder="Street address, P.O. box, etc.">
                    </div>
                </div>

                <div class="field">
                    <label class="label">Address Line 2 (Optional)</label>
                    <div class="control">
                        <input type="text" class="input" v-model="address.address_line2" placeholder="Apartment, suite, unit, building, floor, etc.">
                    </div>
                </div>

                <div class="columns">
                    <div class="column">
                        <div class="field">
                            <label class="label">City</label>
                            <div class="control">
                                <input type="text" class="input" v-model="address.city" placeholder="City">
                            </div>
                        </div>
                    </div>
                    <div class="column">
                        <div class="field">
                            <label class="label">State/Province</label>
                            <div class="control">
                                <input type="text" class="input" v-model="address.state" placeholder="State">
                            </div>
                        </div>
                    </div>
                    <div class="column">
                        <div class="field">
                            <label class="label">ZIP/Postal Code</label>
                            <div class="control">
                                <input type="text" class="input" v-model="address.zip_code" placeholder="ZIP code">
                            </div>
                        </div>
                    </div>
                </div>

                <div class="field">
                    <label class="label">Phone Number</label>
                    <div class="control">
                        <input type="tel" class="input" v-model="address.phone" placeholder="Phone number">
                    </div>
                </div>

                <div class="field">
                    <div class="control">
                        <label class="checkbox">
                            <input type="checkbox" v-model="address.is_default">
                            Set as default address
                        </label>
                    </div>
                </div>

                <div class="field is-grouped mt-5">
                    <div class="control">
                        <button type="submit" class="button is-primary" :class="{'is-loading': isSubmitting}">
                            {{ isEdit ? 'Update Address' : 'Save Address' }}
                        </button>
                    </div>
                    <div class="control">
                        <router-link to="/my-account/addresses" class="button is-light">
                            Cancel
                        </router-link>
                    </div>
                </div>
            </form>
        </div>
    </div>
</template>

<script>
import axios from 'axios'

export default {
    name: 'AddressForm',
    data() {
        return {
            address: {
                name: '',
                address_line1: '',
                address_line2: '',
                city: '',
                state: '',
                zip_code: '',
                phone: '',
                is_default: false
            },
            errors: [],
            isSubmitting: false
        }
    },
    computed: {
        isEdit() {
            return this.$route.params.id !== undefined
        }
    },
    mounted() {
        document.title = this.isEdit ? 'Edit Address | V-Market' : 'Add New Address | V-Market'
        
        if (this.isEdit) {
            this.getAddress()
        }
    },
    methods: {
        async getAddress() {
            this.$store.commit('setIsLoading', true)
            
            try {
                const response = await axios.get(`/api/v1/addresses/${this.$route.params.id}/`)
                this.address = response.data
            } catch (error) {
                console.log(error)
                this.$router.push('/my-account/addresses')
            } finally {
                this.$store.commit('setIsLoading', false)
            }
        },
        validateForm() {
            this.errors = []
            
            if (!this.address.name) {
                this.errors.push('Name is required')
            }
            
            if (!this.address.address_line1) {
                this.errors.push('Address Line 1 is required')
            }
            
            if (!this.address.city) {
                this.errors.push('City is required')
            }
            
            if (!this.address.state) {
                this.errors.push('State is required')
            }
            
            if (!this.address.zip_code) {
                this.errors.push('ZIP Code is required')
            }
            
            if (!this.address.phone) {
                this.errors.push('Phone Number is required')
            }
            
            return this.errors.length === 0
        },
        async saveAddress() {
            if (!this.validateForm()) {
                return
            }
            
            this.isSubmitting = true
            
            try {
                if (this.isEdit) {
                    await axios.put(`/api/v1/addresses/${this.$route.params.id}/`, this.address)
                    this.$store.commit('setNotification', {
                        message: 'Address updated successfully',
                        type: 'is-success'
                    })
                } else {
                    await axios.post('/api/v1/addresses/', this.address)
                    this.$store.commit('setNotification', {
                        message: 'Address created successfully',
                        type: 'is-success'
                    })
                }
                
                this.$router.push('/my-account/addresses')
            } catch (error) {
                console.log(error)
                
                if (error.response && error.response.data) {
                    for (const [key, value] of Object.entries(error.response.data)) {
                        this.errors.push(`${key}: ${value}`)
                    }
                } else {
                    this.errors.push('An error occurred while saving the address')
                }
            } finally {
                this.isSubmitting = false
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
