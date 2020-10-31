---
layout: snippet
author: Carson Evans
---

{% raw %}

```jinja
<div id="success-message" style="display: none;"></div>
<form id="form" method="POST">
    {{ form.csrf_token }}
    <div class="text-danger my-2" id="csrf_token-error">
    </div>
    
    <div class="form-group">
        {{ form.username.label }}
        {{ form.username(class='form-control') }}
        <div id="username-error" class="invalid-feedback"></div>
    </div>
    <div class="form-group">
        {{ form.age.label }}
        {{ form.age(class='form-control') }}
        <div id="age-error" class="invalid-feedback"></div>
    </div>
    <button class="btn btn-primary">Signup</button>
</form>
```

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
