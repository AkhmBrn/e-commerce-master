<template>
    <div class="card">
        <header class="card-header">
            <p class="card-header-title">
                Order #{{ order.id }}
            </p>
            <router-link to="/my-account/orders" class="card-header-icon">
                <span class="icon">
                    <i class="fas fa-arrow-left"></i>
                </span>
                <span>Back to Orders</span>
            </router-link>
        </header>
        <div class="card-content" v-if="order.id">
            <div class="order-status-bar mb-5">
                <div class="columns is-mobile status-timeline">
                    <div class="column has-text-centered" 
                        :class="{'status-active': isStatusActive('pending'), 'status-done': isStatusDone('pending')}">
                        <span class="icon status-icon">
                            <i class="fas fa-check"></i>
                        </span>
                        <p class="status-label mt-2">Ordered</p>
                    </div>
                    <div class="column has-text-centered" 
                        :class="{'status-active': isStatusActive('processing'), 'status-done': isStatusDone('processing')}">
                        <span class="icon status-icon">
                            <i class="fas fa-check"></i>
                        </span>
                        <p class="status-label mt-2">Processing</p>
                    </div>
                    <div class="column has-text-centered" 
                        :class="{'status-active': isStatusActive('shipped'), 'status-done': isStatusDone('shipped')}">
                        <span class="icon status-icon">
                            <i class="fas fa-check"></i>
                        </span>
                        <p class="status-label mt-2">Shipped</p>
                    </div>
                    <div class="column has-text-centered" 
                        :class="{'status-active': isStatusActive('delivered'), 'status-done': isStatusDone('delivered')}">
                        <span class="icon status-icon">
                            <i class="fas fa-check"></i>
                        </span>
                        <p class="status-label mt-2">Delivered</p>
                    </div>
                </div>
            </div>

            <div class="columns">
                <div class="column is-7">
                    <div class="order-info">
                        <div class="panel">
                            <p class="panel-heading is-size-6">
                                Order Information
                            </p>
                            <div class="panel-block">
                                <div class="info-grid">
                                    <span class="info-label">Order Date:</span>
                                    <span class="info-value">{{ formatDate(order.created_at) }}</span>
                                    
                                    <span class="info-label">Status:</span>
                                    <span class="info-value">
                                        <span class="tag" :class="getStatusClass(order.status)">
                                            {{ order.status }}
                                        </span>
                                    </span>
                                    
                                    <span class="info-label">Payment Method:</span>
                                    <span class="info-value">{{ order.payment_method || 'Credit Card' }}</span>
                                </div>
                            </div>
                        </div>
                        
                        <div class="panel mt-4">
                            <p class="panel-heading is-size-6">
                                Shipping Address
                            </p>
                            <div class="panel-block">
                                <p>{{ order.shipping_address }}</p>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="column is-5">
                    <div class="panel">
                        <p class="panel-heading is-size-6">
                            Order Summary
                        </p>
                        <div class="panel-block">
                            <div class="order-summary full-width">
                                <div class="summary-row">
                                    <span>Subtotal:</span>
                                    <span>${{ parseFloat(order.subtotal || 0).toFixed(2) }}</span>
                                </div>
                                <div class="summary-row">
                                    <span>Shipping:</span>
                                    <span>${{ parseFloat(order.shipping_cost || 0).toFixed(2) }}</span>
                                </div>
                                <div class="summary-row">
                                    <span>Tax:</span>
                                    <span>${{ parseFloat(order.tax || 0).toFixed(2) }}</span>
                                </div>
                                <div class="summary-row total">
                                    <span>Total:</span>
                                    <span>${{ parseFloat(order.total || 0).toFixed(2) }}</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="order-items mt-5">
                <h3 class="title is-5">Order Items</h3>
                <table class="table is-fullwidth">
                    <thead>
                        <tr>
                            <th>Product</th>
                            <th>Price</th>
                            <th>Quantity</th>
                            <th class="has-text-right">Total</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr v-for="item in order.items" :key="item.id">
                            <td>
                                <div class="product-info">
                                    <figure class="image is-48x48 mr-2">
                                        <img 
                                            :src="item.product.image ? item.product.image : 'https://bulma.io/images/placeholders/96x96.png'" 
                                            :alt="item.product.name"
                                        >
                                    </figure>
                                    <div>
                                        <p class="has-text-weight-medium">{{ item.product.name }}</p>
                                    </div>
                                </div>
                            </td>
                            <td>${{ parseFloat(item.product.price).toFixed(2) }}</td>
                            <td>{{ item.quantity }}</td>
                            <td class="has-text-right">${{ parseFloat(item.product.price * item.quantity).toFixed(2) }}</td>
                        </tr>
                    </tbody>
                </table>
            </div>
            
            <div class="has-text-right mt-5">
                <button class="button is-light" @click="printOrder">
                    <span class="icon"><i class="fas fa-print"></i></span>
                    <span>Print Order</span>
                </button>
            </div>
        </div>
        <div v-else class="card-content">
            <div class="has-text-centered p-6">
                <p class="is-size-5">Loading order details...</p>
                <progress class="progress is-primary mt-4" v-if="isLoading"></progress>
            </div>
        </div>
    </div>
</template>

<script>
import axios from 'axios'

export default {
    name: 'OrderDetail',
    data() {
        return {
            order: {},
            isLoading: false,
            orderStatuses: ['pending', 'processing', 'shipped', 'delivered']
        }
    },
    mounted() {
        this.getOrderDetails()
    },
    methods: {
        async getOrderDetails() {
            this.isLoading = true
            this.$store.commit('setIsLoading', true)
            
            try {
                const response = await axios.get(`/api/v1/orders/${this.$route.params.id}/`)
                this.order = response.data
                document.title = `Order #${this.order.id} | V-Market`
            } catch (error) {
                console.log(error)
                this.$router.push('/my-account/orders')
            } finally {
                this.isLoading = false
                this.$store.commit('setIsLoading', false)
            }
        },
        formatDate(dateString) {
            const options = { year: 'numeric', month: 'long', day: 'numeric', hour: '2-digit', minute: '2-digit' }
            return new Date(dateString).toLocaleDateString(undefined, options)
        },
        getStatusClass(status) {
            switch(status.toLowerCase()) {
                case 'pending':
                    return 'is-warning'
                case 'processing':
                    return 'is-info'
                case 'shipped':
                    return 'is-primary'
                case 'delivered':
                    return 'is-success'
                case 'cancelled':
                    return 'is-danger'
                default:
                    return 'is-light'
            }
        },
        getCurrentStatusIndex() {
            const status = this.order.status?.toLowerCase() || 'pending'
            return this.orderStatuses.indexOf(status)
        },
        isStatusActive(status) {
            const currentIndex = this.getCurrentStatusIndex()
            const statusIndex = this.orderStatuses.indexOf(status)
            return currentIndex === statusIndex
        },
        isStatusDone(status) {
            const currentIndex = this.getCurrentStatusIndex()
            const statusIndex = this.orderStatuses.indexOf(status)
            return currentIndex > statusIndex
        },
        printOrder() {
            window.print()
        }
    }
}
</script>

<style scoped>
.status-timeline {
    position: relative;
}

.status-timeline::before {
    content: '';
    position: absolute;
    top: 15px;
    left: 50px;
    right: 50px;
    height: 2px;
    background-color: #dbdbdb;
    z-index: 0;
}

.status-icon {
    width: 30px;
    height: 30px;
    border-radius: 50%;
    background-color: #dbdbdb;
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    position: relative;
    z-index: 1;
    margin: 0 auto;
}

.status-active .status-icon {
    background-color: #3e8ed0;
}

.status-done .status-icon {
    background-color: #48c78e;
}

.status-label {
    font-size: 0.9rem;
}

.info-grid {
    display: grid;
    grid-template-columns: 1fr 2fr;
    gap: 0.75rem;
    width: 100%;
}

.info-label {
    font-weight: 600;
}

.order-summary {
    width: 100%;
}

.full-width {
    width: 100%;
}

.summary-row {
    display: flex;
    justify-content: space-between;
    padding: 0.5rem 0;
    border-bottom: 1px solid #f1f1f1;
}

.summary-row.total {
    border-top: 2px solid #dbdbdb;
    border-bottom: none;
    margin-top: 0.5rem;
    padding-top: 0.5rem;
    font-weight: bold;
    font-size: 1.1rem;
}

.product-info {
    display: flex;
    align-items: center;
}

.mr-2 {
    margin-right: 0.5rem;
}

.mt-2 {
    margin-top: 0.5rem;
}

.mt-4 {
    margin-top: 1rem;
}

.mt-5 {
    margin-top: 1.5rem;
}

.mb-5 {
    margin-bottom: 1.5rem;
}

.p-6 {
    padding: 1.5rem;
}

@media print {
    .card-header, .has-text-right button {
        display: none;
    }
}
</style>
