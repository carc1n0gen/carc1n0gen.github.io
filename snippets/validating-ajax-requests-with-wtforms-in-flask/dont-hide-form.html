---
layout: master
author: Carson Evans
---

<div class="card">

{% raw %}

```html
<script>
const form = document.getElementById('form');
const successMessage = document.getElementById('success-message');
const fields = {
    csrf_token: {
        input: document.getElementById('csrf_token'),
        error: document.getElementById('csrf_token-error')
    },
    username: {
        input: document.getElementById('username'),
        error: document.getElementById('username-error')
    },
    age: {
        input: document.getElementById('age'),
        error: document.getElementById('age-error')
    }
}
form.addEventListener('submit', async (e) => {
    e.preventDefault();
    const response = await fetch('/withajax', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            csrf_token: fields.csrf_token.input.value,
            username: fields.username.input.value,
            age: fields.age.input.value
        })
    });
    if (response.ok) {
        successMessage.innerHTML = await response.text();
        form.style.display = 'none';
        successMessage.style.display = 'block';
    } else {
        const errors = await response.json();
        Object.keys(errors).forEach((key) => {
           fields[key].input.classList.add('is-invalid');
           fields[key].error.innerHTML = errors[key][0];
        });
    }
});
</script>
```
{% endraw %}
    
</div>
