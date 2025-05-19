<template>
    <div class="card">
        <header class="card-header">
            <p class="card-header-title">
                My Addresses
            </p>
            <div class="card-header-icon">
                <router-link to="/my-account/addresses/new" class="button is-primary is-small">
                    <span class="icon">
                        <i class="fas fa-plus"></i>
                    </span>
                    <span>Add New Address</span>
                </router-link>
            </div>
        </header>
        <div class="card-content">
            <div v-if="addresses.length === 0" class="has-text-centered">
                <p class="subtitle is-5 mb-4">You don't have any saved addresses yet.</p>
                <router-link to="/my-account/addresses/new" class="button is-primary">
                    Add New Address
                </router-link>
            </div>
            
            <div v-else>
                <div class="columns is-multiline">
                    <div v-for="address in addresses" :key="address.id" class="column is-6">
                        <div class="card address-card">
                            <div class="card-content">
                                <div class="address-header">
                                    <div>
                                        <p class="title is-5">{{ address.name }}</p>
                                        <p v-if="address.is_default" class="tag is-success is-light">Default</p>
                                    </div>
                                    <div class="address-actions">
                                        <div class="dropdown is-right" :class="{'is-active': activeDropdown === address.id}">
                                            <div class="dropdown-trigger">
                                                <button class="button is-small" @click="toggleDropdown(address.id)">
                                                    <span class="icon">
                                                        <i class="fas fa-ellipsis-v"></i>
                                                    </span>
                                                </button>
                                            </div>
                                            <div class="dropdown-menu">
                                                <div class="dropdown-content">
                                                    <router-link :to="'/my-account/addresses/' + address.id" class="dropdown-item">
                                                        <span class="icon"><i class="fas fa-edit"></i></span>
                                                        <span>Edit</span>
                                                    </router-link>
                                                    <a v-if="!address.is_default" class="dropdown-item" @click="setDefaultAddress(address.id)">
                                                        <span class="icon"><i class="fas fa-check"></i></span>
                                                        <span>Set as Default</span>
                                                    </a>
                                                    <hr class="dropdown-divider">
                                                    <a class="dropdown-item has-text-danger" @click="confirmDelete(address)">
                                                        <span class="icon"><i class="fas fa-trash-alt"></i></span>
                                                        <span>Delete</span>
                                                    </a>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                
                                <div class="address-content mt-3">
                                    <p>{{ address.address_line1 }}</p>
                                    <p v-if="address.address_line2">{{ address.address_line2 }}</p>
                                    <p>{{ address.city }}, {{ address.state }} {{ address.zip_code }}</p>
                                    <p class="mt-2"><strong>Phone:</strong> {{ address.phone }}</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Delete Confirmation Modal -->
    <div class="modal" :class="{'is-active': showDeleteModal}">
        <div class="modal-background" @click="cancelDelete"></div>
        <div class="modal-card">
            <header class="modal-card-head">
                <p class="modal-card-title">Delete Address</p>
                <button class="delete" aria-label="close" @click="cancelDelete"></button>
            </header>
            <section class="modal-card-body">
                <p>Are you sure you want to delete this address?</p>
                <p v-if="addressToDelete" class="mt-3">
                    <strong>{{ addressToDelete.name }}</strong><br>
                    {{ addressToDelete.address_line1 }}<br>
                    <span v-if="addressToDelete.address_line2">{{ addressToDelete.address_line2 }}<br></span>
                    {{ addressToDelete.city }}, {{ addressToDelete.state }} {{ addressToDelete.zip_code }}
                </p>
            </section>
            <footer class="modal-card-foot">
                <button class="button is-danger" @click="deleteAddress" :class="{'is-loading': isDeleting}">Delete</button>
                <button class="button" @click="cancelDelete">Cancel</button>
            </footer>
        </div>
    </div>
</template>

<script>
import axios from 'axios'

export default {
    name: 'Addresses',
    data() {
        return {
            addresses: [],
            activeDropdown: null,
            showDeleteModal: false,
            addressToDelete: null,
            isDeleting: false
        }
    },
    mounted() {
        document.title = 'My Addresses | V-Market'
        this.getAddresses()
        
        // Close dropdown when clicking outside
        document.addEventListener('click', this.closeDropdowns)
    },
    beforeUnmount() {
        document.removeEventListener('click', this.closeDropdowns)
    },
    methods: {
        async getAddresses() {
            this.$store.commit('setIsLoading', true)
            try {
                const response = await axios.get('/api/v1/addresses/')
                this.addresses = response.data
            } catch (error) {
                console.log(error)
            } finally {
                this.$store.commit('setIsLoading', false)
            }
        },
        toggleDropdown(id, event) {
            if (event) {
                event.stopPropagation()
            }
            
            if (this.activeDropdown === id) {
                this.activeDropdown = null
            } else {
                this.activeDropdown = id
            }
        },
        closeDropdowns(event) {
            if (!event.target.closest('.dropdown')) {
                this.activeDropdown = null
            }
        },
        confirmDelete(address) {
            this.addressToDelete = address
            this.showDeleteModal = true
            this.activeDropdown = null
        },
        cancelDelete() {
            this.showDeleteModal = false
            this.addressToDelete = null
        },
        async deleteAddress() {
            if (!this.addressToDelete) return
            
            this.isDeleting = true
            
            try {
                await axios.delete(`/api/v1/addresses/${this.addressToDelete.id}/`)
                
                // Remove from local array
                this.addresses = this.addresses.filter(a => a.id !== this.addressToDelete.id)
                
                // Close modal
                this.showDeleteModal = false
                this.addressToDelete = null
                
                // Show notification
                this.$store.commit('setNotification', {
                    message: 'Address deleted successfully',
                    type: 'is-success'
                })
                
            } catch (error) {
                console.log(error)
                this.$store.commit('setNotification', {
                    message: 'Failed to delete address',
                    type: 'is-danger'
                })
            } finally {
                this.isDeleting = false
            }
        },
        async setDefaultAddress(id) {
            this.activeDropdown = null
            this.$store.commit('setIsLoading', true)
            
            try {
                await axios.post(`/api/v1/addresses/${id}/set_default/`)
                
                // Update local data
                this.addresses = this.addresses.map(address => ({
                    ...address,
                    is_default: address.id === id
                }))
                
                // Show notification
                this.$store.commit('setNotification', {
                    message: 'Default address updated',
                    type: 'is-success'
                })
                
            } catch (error) {
                console.log(error)
                this.$store.commit('setNotification', {
                    message: 'Failed to update default address',
                    type: 'is-danger'
                })
            } finally {
                this.$store.commit('setIsLoading', false)
            }
        }
    }
}
</script>

<style scoped>
.address-card {
    height: 100%;
    transition: all 0.2s ease;
}

.address-card:hover {
    box-shadow: 0 4px 8px rgba(0,0,0,0.1);
}

.address-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
}

.address-actions {
    margin-left: auto;
}

.mt-2 {
    margin-top: 0.5rem;
}

.mt-3 {
    margin-top: 0.75rem;
}

.mb-4 {
    margin-bottom: 1rem;
}
</style>
