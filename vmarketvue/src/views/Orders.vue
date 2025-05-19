<template>
    <div class="card">
        <header class="card-header">
            <p class="card-header-title">
                My Orders
            </p>
        </header>
        <div class="card-content">
            <div v-if="orders.length === 0" class="has-text-centered">
                <p class="subtitle is-5 mb-4">You haven't placed any orders yet.</p>
                <router-link to="/" class="button is-primary">
                    Start Shopping
                </router-link>
            </div>
            
            <div v-else>
                <div class="order-list">
                    <div v-for="order in orders" :key="order.id" class="order-item card mb-4">
                        <div class="card-content p-4">
                            <div class="columns is-mobile">
                                <div class="column is-7">
                                    <div class="order-header">
                                        <p class="title is-5">Order #{{ order.id }}</p>
                                        <p class="subtitle is-6 mb-2">{{ formatDate(order.created_at) }}</p>
                                        <span class="tag" :class="getStatusClass(order.status)">
                                            {{ order.status }}
                                        </span>
                                    </div>
                                </div>
                                <div class="column is-5 has-text-right">
                                    <p class="title is-5">${{ parseFloat(order.total).toFixed(2) }}</p>
                                    <p class="subtitle is-6 mb-2">{{ order.items.length }} item(s)</p>
                                    <router-link :to="'/my-account/orders/' + order.id" class="button is-small is-primary">
                                        View Details
                                    </router-link>
                                </div>
                            </div>
                            
                            <div class="order-items mt-4">
                                <div v-for="(item, index) in order.items.slice(0, 2)" :key="index" class="columns is-mobile">
                                    <div class="column is-2">
                                        <figure class="image is-64x64">
                                            <img 
                                                :src="item.product.image ? item.product.image : 'https://bulma.io/images/placeholders/128x128.png'" 
                                                :alt="item.product.name"
                                            >
                                        </figure>
                                    </div>
                                    <div class="column is-8">
                                        <p class="is-6 has-text-weight-medium">{{ item.product.name }}</p>
                                        <p class="is-7">Qty: {{ item.quantity }}</p>
                                    </div>
                                    <div class="column is-2 has-text-right">
                                        <p class="is-6">${{ parseFloat(item.product.price).toFixed(2) }}</p>
                                    </div>
                                </div>
                                <div v-if="order.items.length > 2" class="has-text-centered mt-2">
                                    <p class="is-6 has-text-grey">
                                        +{{ order.items.length - 2 }} more item(s)
                                    </p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
import axios from 'axios'

export default {
    name: 'Orders',
    data() {
        return {
            orders: []
        }
    },
    mounted() {
        document.title = 'My Orders | V-Market'
        this.getOrders()
    },
    methods: {
        async getOrders() {
            this.$store.commit('setIsLoading', true)
            try {
                const response = await axios.get('/api/v1/orders/')
                this.orders = response.data
            } catch (error) {
                console.log(error)
            } finally {
                this.$store.commit('setIsLoading', false)
            }
        },
        formatDate(dateString) {
            const options = { year: 'numeric', month: 'short', day: 'numeric' }
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
        }
    }
}
</script>

<style scoped>
.order-item {
    transition: all 0.2s ease;
}

.order-item:hover {
    box-shadow: 0 4px 8px rgba(0,0,0,0.1);
}

.mt-2 {
    margin-top: 0.5rem;
}

.mt-4 {
    margin-top: 1rem;
}

.mb-2 {
    margin-bottom: 0.5rem;
}

.mb-4 {
    margin-bottom: 1rem;
}

.p-4 {
    padding: 1rem;
}

.order-items {
    border-top: 1px solid #f1f1f1;
    padding-top: 1rem;
}
</style>
