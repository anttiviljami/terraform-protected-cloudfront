<style>
  main {
    text-align: center;
    padding: 1em;
    max-width: 240px;
    margin: 0 auto;
  }

  h1 {
    color: #ff3e00;
    text-transform: uppercase;
    font-size: 4em;
    font-weight: 100;
  }

  @media (min-width: 640px) {
    main {
      max-width: none;
    }
  }
</style>

<main>
  <h1>Hello World!</h1>
  <p>
    It works! This is the default origin for the
    <code>terraform-protected-cloudfront</code>
    module.
  </p>
  <p>
    You can now configure a custom
    <a
      href="https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution#origin">
      <code>origin</code>
    </a>
    for your app.
  </p>
</main>
